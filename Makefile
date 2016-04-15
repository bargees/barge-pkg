BUILDER := ailispaw/docker-root-pkg
VERSION := 1.3.8

SOURCES := .dockerignore empty.config

EXTRA := extra/Config.in extra/external.mk \
	extra/package/bindfs/Config.in extra/package/bindfs/bindfs.mk \
	extra/package/criu/Config.in extra/package/criu/criu.mk \
	extra/package/criu/0001-Remove-quotes-around-CC-for-buildroot.patch \
	extra/package/ipvsadm/Config.in extra/package/ipvsadm/ipvsadm.mk

build: Dockerfile $(SOURCES) $(EXTRA) | output
	find . -type f -name '.DS_Store' | xargs rm -f
	docker build -t $(BUILDER):$(VERSION) .
	docker run --rm $(BUILDER):$(VERSION) cat /build/libstdcxx.tar.gz > output/docker-root-pkg-libstdcxx-v$(VERSION).tar.gz

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

output:
	mkdir -p $@

clean:
	-docker rmi $(BUILDER):$(VERSION)
	$(RM) docker-root-pkg-*.tar.gz

.PHONY: build release base extra patch vagrant output clean
