################################################################################
#
# singularity
#
################################################################################

SINGULARITY_VERSION = 2.4.5
SINGULARITY_SOURCE = singularity-$(SINGULARITY_VERSION).tar.gz
SINGULARITY_SITE = https://github.com/singularityware/singularity/releases/download/$(SINGULARITY_VERSION)
SINGULARITY_LICENSE = BSD-3-Clause
SINGULARITY_LICENSE_FILES = LICENSE.md

SINGULARITY_DEPENDENCIES = python ca-certificates squashfs getent tar libcurl file

SINGULARITY_MAKE = $(MAKE1)

$(eval $(autotools-package))
