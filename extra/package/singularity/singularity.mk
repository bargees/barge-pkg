################################################################################
#
# singularity
#
################################################################################

SINGULARITY_VERSION = 2.5.1
SINGULARITY_SITE = $(call github,singularityware,singularity,$(SINGULARITY_VERSION))
SINGULARITY_LICENSE = BSD-3-Clause
SINGULARITY_LICENSE_FILES = LICENSE.md

SINGULARITY_DEPENDENCIES = python ca-certificates squashfs getent tar libcurl file libarchive

SINGULARITY_MAKE = $(MAKE1)

define SINGULARITY_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef
SINGULARITY_PRE_CONFIGURE_HOOKS += SINGULARITY_RUN_AUTOGEN

$(eval $(autotools-package))
