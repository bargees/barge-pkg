################################################################################
#
# locales
#
################################################################################

# source included in glibc
LOCALES_SOURCE =

define LOCALES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/locale    $(TARGET_DIR)/usr/bin/locale
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/localedef $(TARGET_DIR)/usr/bin/localedef
	mkdir -p $(TARGET_DIR)/usr/share
	cp -dpfr $(STAGING_DIR)/usr/share/i18n $(TARGET_DIR)/usr/share
endef

$(eval $(generic-package))
