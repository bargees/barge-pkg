BUILDER := ailispaw/barge-pkg
VERSION := 2.12.0

KERNEL_VERSION := 4.14.105

SOURCES := .dockerignore empty.config

EXTRA := $(shell find extra -type f)

# $1: Dockerfile
# $2: image-name:tag
# $3: dependencies
define docker_build
	$(eval SRC_UPDATED=$$(shell stat -f "%m" $3 | sort -gr | head -n1))
	$(eval STR_CREATED=$$(shell docker inspect -f '{{.Created}}' $2 2>/dev/null))
	$(eval IMG_CREATED=`date -j -u -f "%FT%T" "$$(STR_CREATED)" +"%s" 2>/dev/null || echo 0`)
	@if [ "$(SRC_UPDATED)" -gt "$(IMG_CREATED)" ]; then \
		set -e; \
		find . -type f -name '.DS_Store' | xargs rm -f; \
		docker build -f $1 -t $2 .; \
	fi
endef

build: Dockerfile $(SOURCES) $(EXTRA)
	$(call docker_build,$<,$(BUILDER),$^)

tag: | build
	docker tag $(BUILDER) $(BUILDER):$(VERSION)

release: | tag
	docker push $(BUILDER):$(VERSION)

extra: Dockerfile.extra $(EXTRA)
	$(call docker_build,$<,$(BUILDER):$(VERSION),$^)

vagrant:
	vagrant up

clean:
	-docker rmi $(BUILDER):$(VERSION)
	-docker rmi $(BUILDER)

.PHONY: build tag release base extra vagrant clean

config: output/$(VERSION)/buildroot.config

output/$(VERSION)/buildroot.config: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/buildroot/.config > $@

PACKAGES := acl bindfs criu eudev git iproute2 ipvsadm kmod libfuse locales make \
	shadow sshfs su-exec tar tmux tzdata vim \
	dmidecode findutils socat zlib wireguard qemu-ga

EUDEV_OPTIONS       := -e BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y
GIT_OPTIONS         := -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
IPVSADM_OPTIONS     := -e BR2_PACKAGE_LIBNL=y
KMOD_OPTIONS        := -e BR2_PACKAGE_KMOD_TOOLS=y
TMUX_OPTIONS        := -e BR2_PACKAGE_NCURSES_WCHAR=y
TZDATA_OPTIONS      := -e BR2_TARGET_TZ_ZONELIST=default -e BR2_TARGET_LOCALTIME="Etc/UTC"
WIREGUARD_OPTIONS   := -v /vagrant/output/$(VERSION)/kernel.config:/build/kernel.config \
	-e BR2_LINUX_KERNEL=y \
	-e BR2_LINUX_KERNEL_CUSTOM_VERSION=y \
	-e BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\"$(KERNEL_VERSION)\" \
	-e BR2_LINUX_KERNEL_VERSION=\"$(KERNEL_VERSION)\" \
	-e BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG=y \
	-e BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=\"/build/kernel.config\"

packages: libstdcxx $(PACKAGES)

libstdcxx $(filter-out wireguard,$(PACKAGES)): % : output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz

wireguard: % : output/$(VERSION)/kernel.config output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz
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
		sudo mkdir -p /opt/pkg/ccache /opt/pkg/dl && \
		docker run --rm -v $(TMP_DIR):/build/buildroot/output/target \
			-v /opt/pkg/ccache:/build/buildroot/ccache -v /opt/pkg/dl:/build/buildroot/dl \
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
