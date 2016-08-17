################################################################################
#
# CRIU
#
################################################################################

CRIU_VERSION = v2.5
CRIU_SITE = $(call github,xemul,criu,$(CRIU_VERSION))
CRIU_DEPENDENCIES = host-libcap protobuf-c libnl iproute2 tar
CRIU_LICENSE = GPLv2 (programs), LGPLv2.1 (libraries)
CRIU_LICENSE_FILES = COPYING

CRIU_CFLAGS = $(HOST_CFLAGS) --sysroot=$(STAGING_DIR) -I$(STAGING_DIR)/usr/include/libnl3
CRIU_MAKE_OPTS = PREFIX=/usr CC="$(HOSTCC) $(CRIU_CFLAGS) $(HOST_LDFLAGS)" AR="$(HOSTAR)"

define CRIU_BUILD_CMDS
	$(RM) $(@D)/images/google/protobuf/descriptor.proto
	cp $(HOST_DIR)/usr/include/google/protobuf/descriptor.proto $(@D)/images/google/protobuf/
	$(TARGET_MAKE_ENV) $(MAKE1) $(CRIU_MAKE_OPTS) -C $(@D) criu
endef

define CRIU_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) $(CRIU_MAKE_OPTS) -C $(@D) DESTDIR=$(TARGET_DIR) install-criu
endef

$(eval $(generic-package))
