https://kernel.org/pub/linux/utils/kernel/ipvsadm/
################################################################################
#
# ipvsadm
#
################################################################################

IPVSADM_VERSION = 1.28
IPVSADM_SOURCE = ipvsadm-$(IPVSADM_VERSION).tar.gz
IPVSADM_SITE = https://kernel.org/pub/linux/utils/kernel/ipvsadm
IPVSADM_DEPENDENCIES = host-pkgconf host-popt popt
IPVSADM_LICENSE = GPLv2
IPVSADM_LICENSE_FILES = README

IPVSADM_MAKE_ENV = $(TARGET_MAKE_ENV)

ifeq ($(BR2_PACKAGE_LIBNL),y)
IPVSADM_DEPENDENCIES += libnl
IPVSADM_MAKE_ENV += HAVE_NL=1
else
IPVSADM_MAKE_ENV += HAVE_NL=0
endif

define IPVSADM_BUILD_CMDS
	$(IPVSADM_MAKE_ENV) $(MAKE1) \
		CC="$(HOSTCC) --sysroot=$(STAGING_DIR) $(HOST_CFLAGS) $(HOST_LDFLAGS)" \
		AR="$(HOSTAR)" -C $(@D)
endef

define IPVSADM_INSTALL_TARGET_CMDS
	$(IPVSADM_MAKE_ENV) $(MAKE1) BUILD_ROOT=$(TARGET_DIR) INIT=$(TARGET_DIR)/etc/init.d \
		-C $(@D) install
endef

$(eval $(generic-package))
