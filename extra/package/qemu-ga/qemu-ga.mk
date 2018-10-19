################################################################################
#
# qemu-ga
#
################################################################################

QEMU_GA_VERSION = 2.10.2
QEMU_GA_SOURCE = qemu-$(QEMU_GA_VERSION).tar.xz
QEMU_GA_SITE = http://download.qemu.org
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
			--with-system-pixman \
			--audio-drv-list= \
			--enable-kvm \
			--enable-attr \
			--enable-vhost-net \
			--disable-bsd-user \
			--disable-xen \
			--disable-slirp \
			--disable-vnc \
			--disable-virtfs \
			--disable-brlapi \
			--disable-curses \
			--disable-curl \
			--disable-bluez \
			--disable-vde \
			--disable-linux-aio \
			--disable-cap-ng \
			--disable-docs \
			--disable-spice \
			--disable-rbd \
			--disable-libiscsi \
			--disable-usb-redir \
			--disable-strip \
			--disable-seccomp \
			--disable-sparse \
			$(QEMU_GA_OPTS) \
	)
endef

define QEMU_GA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) qemu-ga
endef

define QEMU_GA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/qemu-ga $(TARGET_DIR)/usr/bin/qemu-ga
	$(INSTALL) -D -m 0755 $(QEMU_GA_PKGDIR)/qemu-ga $(TARGET_DIR)/etc/init.d/qemu-ga
endef

$(eval $(generic-package))
