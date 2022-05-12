BUILDER := ailispaw/barge-pkg
VERSION := 3.0.0-dev

KERNEL_VERSION := 4.14.269

SOURCES := .dockerignore empty.config build.sh \
	$(shell find patches -type f)

EXTRA := $(shell find extra -type f)

TMP_BUILD_IMAGE     := barge-pkg-builder
TMP_BUILD_CONTAINER := barge-pkg-built

DL_DIR     := /mnt/data/dl
CCACHE_DIR := /mnt/data/ccache

# $1: Dockerfile
# $2: image-name:tag
# $3: dependencies
# $4: an intermediate image to build
# $5: an intermediate container to build
define docker_build
	$(eval SRC_UPDATED=$$(shell stat -f "%m" $3 | sort -gr | head -n1))
	@echo "SRC_UPDATED=`date -r $(SRC_UPDATED)`"

	@set -e; \
	IMG_CREATED=`docker inspect -f '{{.Created}}' $4 2>/dev/null || true`; \
	IMG_CREATED=`date -j -u -f "%FT%T" "$${IMG_CREATED}" +"%s" 2>/dev/null || echo 0`; \
	echo "IMG_CREATED=`date -r $${IMG_CREATED}`"; \
	if [ "$(SRC_UPDATED)" -gt "$${IMG_CREATED}" ]; then \
		find . -type f -name '.DS_Store' | xargs rm -f; \
		docker build -f $1 -t $4 .; \
		IMG_CREATED2=`docker inspect -f '{{.Created}}' $4 2>/dev/null || true`; \
		IMG_CREATED2=`date -j -u -f "%FT%T" "$${IMG_CREATED2}" +"%s" 2>/dev/null || echo 0`; \
		echo "IMG_CREATED2=`date -r $${IMG_CREATED2}`"; \
		if [ "$${IMG_CREATED2}" -gt "$(SRC_UPDATED)" ]; then \
			(docker rm -f $5 || true); \
		fi; \
	fi

	@set -e; \
	CTN_EXISTS=`docker ps -aq -f name='$5$$' -f exited=0`; \
	echo "CTN_EXISTS=$${CTN_EXISTS}"; \
	if [ -z "$${CTN_EXISTS}" ]; then \
		(docker rm -f $5 || true); \
		docker run --privileged -v $(DL_DIR):/build/buildroot/dl \
			-v $(CCACHE_DIR):/build/buildroot/ccache --name $5 $4; \
	fi

	@set -e; \
	CTN_FINISHED=`docker inspect -f '{{.State.FinishedAt}}' $5 2>/dev/null || true`; \
	CTN_FINISHED=`date -j -u -f "%FT%T" "$${CTN_FINISHED}" +"%s" 2>/dev/null || echo 0`; \
	echo "CTN_FINISHED=`date -r $${CTN_FINISHED}`"; \
	PKG_CREATED=`docker inspect -f '{{.Created}}' $2 2>/dev/null || true`; \
	PKG_CREATED=`date -j -u -f "%FT%T" "$${PKG_CREATED}" +"%s" 2>/dev/null || echo 0`; \
	echo "PKG_CREATED=`date -r $${PKG_CREATED}`"; \
	if [ "$${CTN_FINISHED}" -gt "$${PKG_CREATED}" ]; then \
		docker export $5 | docker import \
			-c 'VOLUME /build/buildroot/dl /build/buildroot/ccache' \
			-c 'WORKDIR /build/buildroot' \
			-m 'https://github.com/bargees/barge-pkg' \
			- $2; \
	fi
endef

build: Dockerfile $(SOURCES) $(EXTRA)
	$(call docker_build,$<,$(BUILDER),$^,$(TMP_BUILD_IMAGE),$(TMP_BUILD_CONTAINER))

tag: | build
	docker tag $(BUILDER) $(BUILDER):$(VERSION)

release: | tag
	docker push $(BUILDER):$(VERSION)

extra: Dockerfile.extra $(EXTRA)
	$(call docker_build,$<,$(BUILDER):$@,$^,$(TMP_BUILD_IMAGE)-$@,$(TMP_BUILD_CONTAINER)-$@)

vagrant:
	vagrant up
	vagrant ssh -c 'sudo mkdir -p $(DL_DIR) $(CCACHE_DIR)'

clean:
	-docker rm -f $(TMP_BUILD_CONTAINER)
	-docker rm -f $(TMP_BUILD_CONTAINER)-extra
	-docker rmi `docker images -q -f dangling=true`
	-docker rmi $(TMP_BUILD_IMAGE)
	-docker rmi $(TMP_BUILD_IMAGE)-extra
	-docker rmi $(BUILDER):$(VERSION)
	-docker rmi $(BUILDER)
	-docker rmi $(BUILDER):extra

.PHONY: build tag release base extra vagrant clean

config: output/$(VERSION)/buildroot.config

output/$(VERSION)/buildroot.config: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/buildroot/.config > $@

PACKAGES := acl bindfs criu eudev git iproute2 ipvsadm kmod libfuse locales make \
	shadow sshfs su-exec tar tmux tzdata vim \
	dmidecode findutils socat zlib wireguard-linux-compat wireguard-tools qemu-ga

EUDEV_OPTIONS       := -e BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y
GIT_OPTIONS         := -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
IPVSADM_OPTIONS     := -e BR2_PACKAGE_LIBNL=y
KMOD_OPTIONS        := -e BR2_PACKAGE_KMOD_TOOLS=y
TMUX_OPTIONS        := -e BR2_PACKAGE_NCURSES_WCHAR=y
TZDATA_OPTIONS      := -e BR2_TARGET_TZ_ZONELIST=default -e BR2_TARGET_LOCALTIME="Etc/UTC"
WIREGUARD_LINUX_COMPAT_OPTIONS := -v /vagrant/output/$(VERSION)/kernel.config:/build/kernel.config \
	-e BR2_LINUX_KERNEL=y \
	-e BR2_LINUX_KERNEL_CUSTOM_VERSION=y \
	-e BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\"$(KERNEL_VERSION)\" \
	-e BR2_LINUX_KERNEL_VERSION=\"$(KERNEL_VERSION)\" \
	-e BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG=y \
	-e BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=\"/build/kernel.config\"

packages: libstdcxx $(PACKAGES)

libstdcxx $(filter-out wireguard-linux-compat,$(PACKAGES)): % : output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz

wireguard-linux-compat: % : output/$(VERSION)/kernel.config output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz
	$(eval TMP_DIR=/tmp/barge-pkg-$*-$(VERSION))
	vagrant ssh -c ' \
		sudo tar -zc -f /vagrant/output/$(VERSION)/barge-pkg-$*-$(VERSION).tar.gz -C $(TMP_DIR) \
			--exclude "./lib/modules/$(KERNEL_VERSION)-barge/kernel" \
			--exclude "./lib/modules/$(KERNEL_VERSION)-barge/modules.*" .' -- -T

output/$(VERSION)/kernel.config:
	curl -L https://raw.githubusercontent.com/bargees/barge-os/$(VERSION)/configs/$(@F) -o $@

output/$(VERSION)/barge-pkg-libstdcxx-$(VERSION).tar.gz: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/libstdcxx.tar.gz > $@

$(PACKAGES:%=output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz): \
	output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz: | output
	$(eval TMP_DIR=/tmp/barge-pkg-$*-$(VERSION))
	vagrant ssh -c 'set -e; \
		sudo rm -rf $(TMP_DIR) && sudo mkdir -p $(TMP_DIR) && \
		for i in bin dev/pts etc/ld.so.conf.d etc/network lib sbin usr/bin usr/lib usr/sbin var/lib/misc; do \
			sudo mkdir -p $(TMP_DIR)/$$i; \
		done; \
		docker run --rm -v $(TMP_DIR):/build/buildroot/output/target \
			-v $(DL_DIR):/build/buildroot/dl -v $(CCACHE_DIR):/build/buildroot/ccache \
			$($(shell echo $* | tr a-z- A-Z_)_OPTIONS) \
			$(BUILDER):$(VERSION) sh -c " \
				cp .config .config.org && \
				echo BR2_PACKAGE_$(shell echo $* | tr a-z- A-Z_)=y >> .config && \
				(env | grep ^BR2_ >> .config || true) && \
				(make oldconfig || make oldconfig) && \
				(diff .config .config.org || true) && \
				make --quiet $* \
			"; \
		sudo tar -zc -f /vagrant/$@ -C $(TMP_DIR) .' -- -T

output:
	@mkdir -p $@/$(VERSION)

distclean:
	$(RM) -r output

.PHONY: config packages libstdcxx $(PACKAGES) output distclean
