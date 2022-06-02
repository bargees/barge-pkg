################################################################################
#
# shadow
#
################################################################################

SHADOW_VERSION = 4.11.1
SHADOW_SOURCE = shadow-$(SHADOW_VERSION).tar.xz
SHADOW_SITE = https://github.com/shadow-maint/shadow/releases/download/v$(SHADOW_VERSION)
SHADOW_LICENSE = BSD-3c
SHADOW_LICENSE_FILES = COPYING
SHADOW_DEPENDENCIES = acl attr

SHADOW_INSTALL_STAGING = NO

SHADOW_CONF_OPTS = --sysconfdir=/etc --with-group-name-max-length=32 --disable-nls

# Shadow configuration to support audit
ifeq ($(BR2_PACKAGE_AUDIT),y)
SHADOW_DEPENDENCIES += audit
SHADOW_CONF_OPTS += --with-audit=yes
endif

# Shadow with linux-pam support
ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
SHADOW_DEPENDENCIES += linux-pam
SHADOW_CONF_OPTS += --with-libpam=yes

# Comment out all config entries that conflict with using PAM
define SHADOW_LOGIN_CONFIGURATION
	for FUNCTION in FAIL_DELAY FAILLOG_ENAB LASTLOG_ENAB MAIL_CHECK_ENAB \
		OBSCURE_CHECKS_ENAB PORTTIME_CHECKS_ENAB QUOTAS_ENAB CONSOLE MOTD_FILE \
		FTMP_FILE NOLOGINS_FILE ENV_HZ PASS_MIN_LEN SU_WHEEL_ONLY CRACKLIB_DICTPATH \
		PASS_CHANGE_TRIES PASS_ALWAYS_WARN CHFN_AUTH ENCRYPT_METHOD ENVIRON_FILE ; \
	do \
		$(SED) "s/^$${FUNCTION}/# &/" $(TARGET_DIR)/etc/login.defs ; \
	done
endef
SHADOW_POST_INSTALL_TARGET_HOOKS += SHADOW_LOGIN_CONFIGURATION
endif

# Shadow with selinux support
ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
SHADOW_DEPENDENCIES += libselinux libsemanage
SHADOW_CONF_OPTS += --with-selinux=yes
endif

$(eval $(autotools-package))
