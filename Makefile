BUILDER := ailispaw/docker-root-pkg
VERSION := 1.3.9

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

base: Dockerfile.base $(SOURCES)
	$(eval SRC_UPDATED=$$(shell stat -f "%m" $^ | sort -gr | head -n1))
	$(eval STR_CREATED=$$(shell docker inspect -f '{{.Created}}' $(BUILDER):$@ 2>/dev/null))
	$(eval IMG_CREATED=`date -j -u -f "%FT%T" "$$(STR_CREATED)" +"%s" 2>/dev/null || echo 0`)
	@if [ "$(SRC_UPDATED)" -gt "$(IMG_CREATED)" ]; then \
		set -e; \
		docker build -f $< -t $(BUILDER):$@ .; \
	fi

extra: Dockerfile.extra $(EXTRA) | base
	$(eval SRC_UPDATED=$$(shell stat -f "%m" $^ | sort -gr | head -n1))
	$(eval STR_CREATED=$$(shell docker inspect -f '{{.Created}}' $(BUILDER):$(VERSION) 2>/dev/null))
	$(eval IMG_CREATED=`date -j -u -f "%FT%T" "$$(STR_CREATED)" +"%s" 2>/dev/null || echo 0`)
	@if [ "$(SRC_UPDATED)" -gt "$(IMG_CREATED)" ]; then \
		set -e; \
		find . -type f -name '.DS_Store' | xargs rm -f; \
		docker build -f $< -t $(BUILDER):$(VERSION) .; \
	fi

patch: Dockerfile.patch
	docker build -f $< -t $(BUILDER):$(VERSION)-patched .
	docker tag $(BUILDER):$(VERSION) $(BUILDER):$(VERSION)-org
	docker rmi $(BUILDER):$(VERSION)
	docker tag $(BUILDER):$(VERSION)-patched $(BUILDER):$(VERSION)

vagrant:
	vagrant up

clean:
	-docker rmi $(BUILDER):$(VERSION)

.PHONY: build release base extra patch vagrant clean

config: output/v$(VERSION)/buildroot.config

output/v$(VERSION)/buildroot.config: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/buildroot/.config > $@

PACKAGES := libstdcxx bindfs criu git ipvsadm libfuse sshfs tzdata vim

IPVSADM_OPTIONS := -e BR2_PACKAGE_LIBNL=y
GIT_OPTIONS     := -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
TZDATA_OPTIONS  := -e BR2_TARGET_TZ_ZONELIST=default

packages: $(PACKAGES)

$(PACKAGES): % : output/v$(VERSION)/docker-root-pkg-%-v$(VERSION).tar.gz

output/v$(VERSION)/docker-root-pkg-libstdcxx-v$(VERSION).tar.gz: | output
	docker run --rm $(BUILDER):$(VERSION) cat /build/libstdcxx.tar.gz > $@

output/v$(VERSION)/docker-root-pkg-bindfs-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-criu-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-git-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-ipvsadm-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-libfuse-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-sshfs-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-tzdata-v$(VERSION).tar.gz \
output/v$(VERSION)/docker-root-pkg-vim-v$(VERSION).tar.gz: \
	output/v$(VERSION)/docker-root-pkg-%-v$(VERSION).tar.gz: | output
	$(eval TMP_DIR=/tmp/docker-root-pkg-$*-v$(VERSION))
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
	mkdir -p $@/v$(VERSION)

distclean:
	$(RM) -r output

.PHONY: config packages $(PACKAGES) output distclean
