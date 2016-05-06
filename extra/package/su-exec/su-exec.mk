################################################################################
#
# su-exec
#
################################################################################

SU_EXEC_VERSION = 0.2
SU_EXEC_SITE = $(call github,ncopa,su-exec,v$(SU_EXEC_VERSION))
SU_EXEC_LICENSE = MIT
SU_EXEC_LICENSE_FILES = LICENSE

SU_EXEC_CFLAGS = $(HOST_CFLAGS) -s -Os -Wall -Werror

define SU_EXEC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC="$(HOSTCC) $(SU_EXEC_CFLAGS) $(HOST_LDFLAGS)" AR="$(HOSTAR)" \
		-C $(@D)
endef

define SU_EXEC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/su-exec $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
