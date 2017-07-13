BUILDER := ailispaw/barge-pkg
VERSION := 2.6.2-arm64v8

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

PACKAGES := acl alsa-utils avahi bindfs bluez5_utils file git i2c-tools iproute2 ipvsadm \
	libcap libcgroup libfuse locales make mjpg-streamer shadow sshfs su-exec tar tmux tzdata vim

ALSA_UTILS_OPTIONS := -e BR2_PACKAGE_ALSA_UTILS_AMIXER=y -e BR2_PACKAGE_ALSA_UTILS_APLAY=y  \
	-e BR2_PACKAGE_ALSA_UTILS_SPEAKER_TEST=y -e BR2_PACKAGE_ALSA_UTILS_ALSACONF=y
AVAHI_OPTIONS	:= -e BR2_PACKAGE_AVAHI_DAEMON=y
BLUEZ5_UTILS_OPTIONS := -e BR2_PACKAGE_BLUEZ5_UTILS_CLIENT=y -e BR2_PACKAGE_BLUEZ5_UTILS_DEPRECATED=y
GIT_OPTIONS     := -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
IPVSADM_OPTIONS := -e BR2_PACKAGE_LIBNL=y
LIBCAP_OPTIONS    := -e BR2_PACKAGE_LIBCAP_TOOLS=y
LIBCGROUP_OPTIONS := -e BR2_PACKAGE_LIBCGROUP_TOOLS=y
MJPG_STREAMER_OPTIONS := -e BR2_PACKAGE_LIBV4L=y -e BR2_PACKAGE_JPEG=y -e BR2_PACKAGE_LIBJPEG=y \
	-e BR2_PACKAGE_HAS_JPEG=y -e BR2_PACKAGE_PROVIDES_JPEG="libjpeg"
TMUX_OPTIONS    := -e BR2_PACKAGE_NCURSES_WCHAR=y
TZDATA_OPTIONS  := -e BR2_TARGET_TZ_ZONELIST=default -e BR2_TARGET_LOCALTIME="Etc/UTC"

packages: libstdcxx $(PACKAGES)

libstdcxx $(PACKAGES): % : output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz

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
