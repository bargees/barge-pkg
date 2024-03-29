################################################################################
#
# CRIU
#
################################################################################

CRIU_VERSION = v3.17
CRIU_SITE = $(call github,checkpoint-restore,criu,$(CRIU_VERSION))
CRIU_DEPENDENCIES = libcap protobuf-c libnl libnet iproute2 tar libbsd
CRIU_LICENSE = GPLv2 (programs), LGPLv2.1 (libraries)
CRIU_LICENSE_FILES = COPYING

CRIU_MAKE_ENV = $(TARGET_MAKE_ENV)
CRIU_CFLAGS = $(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/libnl3 \
	-D_SYS_RSEQ_H

ifeq ($(BR2_x86_64),y)
CRIU_HOSTCFLAGS = -DCONFIG_X86_64
else
CRIU_MAKE_ENV += ARCH=$(BR2_ARCH) CROSS_COMPILE="$(TARGET_CROSS)" HOSTLD="ld"
endif
ifeq ($(BR2_arm),y)
ifeq ($(BR2_ARM_CPU_ARMV6),y)
CRIU_CFLAGS += -march=armv6
CRIU_HOSTCFLAGS = -DCONFIG_ARMV6 -DNO_RELOCS -DCONFIG_VDSO_32
else ifeq ($(BR2_ARM_CPU_ARMV7A)$(BR2_ARM_CPU_ARMV8A),y)
CRIU_CFLAGS += -march=armv7-a
CRIU_HOSTCFLAGS = -DCONFIG_ARMV7 -DNO_RELOCS -DCONFIG_VDSO_32
endif
endif

CRIU_MAKE_OPTS = PREFIX=/usr CC="$(TARGET_CC) $(CRIU_CFLAGS) $(TARGET_LDFLAGS)" \
	HOSTCFLAGS="$(CRIU_HOSTCFLAGS)" LD="$(TARGET_LD)"

define CRIU_BUILD_CMDS
	$(RM) $(@D)/images/google/protobuf/descriptor.proto
	cp $(HOST_DIR)/include/google/protobuf/descriptor.proto $(@D)/images/google/protobuf/
	$(CRIU_MAKE_ENV) $(MAKE1) $(CRIU_MAKE_OPTS) -C $(@D) criu
endef

define CRIU_INSTALL_TARGET_CMDS
	$(CRIU_MAKE_ENV) $(MAKE1) $(CRIU_MAKE_OPTS) -C $(@D) DESTDIR=$(TARGET_DIR) install-criu
endef

$(eval $(generic-package))
