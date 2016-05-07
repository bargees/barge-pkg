BUILDER := ailispaw/barge-pkg
VERSION := 2.0.1

SOURCES := .dockerignore empty.config

EXTRA := extra/Config.in extra/external.mk \
	extra/package/bindfs/Config.in extra/package/bindfs/bindfs.mk \
	extra/package/criu/Config.in extra/package/criu/criu.mk \
	extra/package/criu/0001-Remove-quotes-around-CC-for-buildroot.patch \
	extra/package/criu/0002-Add-quotes-around-HOSTCC-and-HOSTLD-for-buildroot.patch \
	extra/package/ipvsadm/Config.in extra/package/ipvsadm/ipvsadm.mk

build: Dockerfile $(SOURCES) $(EXTRA)
	find . -type f -name '.DS_Store' | xargs rm -f
	docker build -t $(BUILDER):$(VERSION) .

release: build
	docker push $(BUILDER):$(VERSION)

base:
	docker tag -f $(BUILDER):$(VERSION) $(BUILDER):base

extra: Dockerfile.extra $(EXTRA)
	$(eval SRC_UPDATED=$$(shell stat -f "%m" $^ | sort -gr | head -n1))
	$(eval STR_CREATED=$$(shell docker inspect -f '{{.Created}}' $(BUILDER):$(VERSION) 2>/dev/null))
	$(eval IMG_CREATED=`date -j -u -f "%FT%T" "$$(STR_CREATED)" +"%s" 2>/dev/null || echo 0`)
	@if [ "$(SRC_UPDATED)" -gt "$(IMG_CREATED)" ]; then \
		set -e; \
		find . -type f -name '.DS_Store' | xargs rm -f; \
		docker build -f $< -t $(BUILDER):$(VERSION) .; \
	fi

vagrant:
	vagrant up

clean:
	-docker rmi $(BUILDER):$(VERSION)

.PHONY: build release base extra vagrant clean

config: output/$(VERSION)/buildroot.config

output/$(VERSION)/buildroot.config: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/buildroot/.config > $@

PACKAGES := libstdcxx bindfs criu git ipvsadm libfuse sshfs tzdata vim

IPVSADM_OPTIONS := -e BR2_PACKAGE_LIBNL=y
GIT_OPTIONS     := -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
TZDATA_OPTIONS  := -e BR2_TARGET_TZ_ZONELIST=default

packages: $(PACKAGES)

$(PACKAGES): % : output/$(VERSION)/barge-pkg-%-$(VERSION).tar.gz

output/$(VERSION)/barge-pkg-libstdcxx-$(VERSION).tar.gz: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/libstdcxx.tar.gz > $@

output/$(VERSION)/barge-pkg-bindfs-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-criu-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-git-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-ipvsadm-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-libfuse-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-sshfs-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-tzdata-$(VERSION).tar.gz \
output/$(VERSION)/barge-pkg-vim-$(VERSION).tar.gz: \
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
			$($(shell echo $* | tr a-z A-Z)_OPTIONS) \
			$(BUILDER):$(VERSION) make --quiet $*; \
		sudo tar -zc -f /vagrant/$@ -C $(TMP_DIR) .' -- -T

output:
	mkdir -p $@/$(VERSION)

distclean:
	$(RM) -r output

.PHONY: config packages $(PACKAGES) output distclean
