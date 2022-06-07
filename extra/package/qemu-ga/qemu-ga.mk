################################################################################
#
# qemu-ga
#
################################################################################

QEMU_GA_VERSION = 7.0.0
QEMU_GA_SOURCE = qemu-$(QEMU_GA_VERSION).tar.xz
QEMU_GA_SITE = https://download.qemu.org
QEMU_GA_LICENSE = GPL-2.0, LGPL-2.1, MIT, BSD-3-Clause, BSD-2-Clause, Others/BSD-1c
QEMU_GA_LICENSE_FILES = COPYING COPYING.LIB
# NOTE: there is no top-level license file for non-(L)GPL licenses;
#       the non-(L)GPL license texts are specified in the affected
#       individual source files.

#-------------------------------------------------------------
# Target-qemu-ga

QEMU_GA_DEPENDENCIES = host-pkgconf host-flex libglib2 pixman

QEMU_GA_LIBS =

QEMU_GA_OPTS = --sysconfdir=/etc --localstatedir=/var

QEMU_GA_VARS =

# Override CPP, as it expects to be able to call it like it'd
# call the compiler.
define QEMU_GA_CONFIGURE_CMDS
	( cd $(@D); \
		LIBS='$(QEMU_GA_LIBS)' \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CPP="$(TARGET_CC) -E" \
		$(QEMU_GA_VARS) \
		./configure \
			--prefix=/usr \
			--cross-prefix=$(TARGET_CROSS) \
			--disable-sanitizers \
			--audio-drv-list= \
			\
			--enable-kvm \
			--enable-attr \
			--enable-vhost-net \
			\
			--disable-capstone \
			--disable-slirp \
			--disable-strip \
			\
			--disable-brlapi \
			--disable-cap-ng \
			--disable-curl \
			--disable-curses \
			--disable-docs \
			--disable-hvf \
			--disable-libiscsi \
			--disable-linux-aio \
			--disable-malloc-trim \
			--disable-membarrier \
			--disable-mpath \
			--disable-rbd \
			--disable-sparse \
			--disable-spice \
			--disable-usb-redir \
			--disable-vde \
			--disable-virtfs \
			--disable-vnc \
			--disable-whpx \
			--disable-xen \
			\
			--disable-bsd-user \
			--disable-vhost-crypto \
			--disable-opengl \
			$(QEMU_GA_OPTS) \
	)
endef

define QEMU_GA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) qemu-ga
endef

define QEMU_GA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/build/qga/qemu-ga $(TARGET_DIR)/usr/bin/qemu-ga
	$(INSTALL) -D -m 0755 $(QEMU_GA_PKGDIR)/qemu-ga $(TARGET_DIR)/etc/init.d/qemu-ga
endef

$(eval $(generic-package))
