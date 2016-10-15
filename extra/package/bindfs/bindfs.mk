################################################################################
#
# bindfs
#
################################################################################

BINDFS_VERSION = 1.13.4
BINDFS_SOURCE = bindfs-$(BINDFS_VERSION).tar.gz
BINDFS_SITE = http://bindfs.org/downloads
BINDFS_DEPENDENCIES = host-pkgconf libfuse
BINDFS_LICENSE = GPLv2
BINDFS_LICENSE_FILES = COPYING

$(eval $(autotools-package))
