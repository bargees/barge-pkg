FROM ailispaw/ubuntu-essential

ENV TERM xterm

RUN apt-get -q update && \
    apt-get -q -y install --no-install-recommends ca-certificates \
      bc build-essential cpio python unzip rsync wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup environment
ENV SRC_DIR=/build \
    BR_ROOT=/build/buildroot
RUN mkdir -p ${SRC_DIR}

ENV BR_VERSION 2015.11.1
RUN wget -qO- http://buildroot.uclibc.org/downloads/buildroot-${BR_VERSION}.tar.bz2 | tar xj && \
    mv buildroot-${BR_VERSION} ${BR_ROOT}

# Apply patches
RUN mkdir -p ${SRC_DIR}/patches && \
    wget -qO ${SRC_DIR}/patches/openssh.patch https://raw.githubusercontent.com/ailispaw/docker-root/master/patches/openssh.patch && \
    patch -p1 -d ${BR_ROOT} < ${SRC_DIR}/patches/openssh.patch && \
    mkdir -p ${BR_ROOT}/package/glibc/2.21 && \
    wget -qO ${BR_ROOT}/package/glibc/2.21/0001-fix-CVE-2015-7547.patch https://raw.githubusercontent.com/ailispaw/docker-root/master/patches/glibc/2.21/0001-fix-CVE-2015-7547.patch

# Copy the empty config file
COPY empty.config ${BR_ROOT}/.config

# Copy extra packages
COPY extra ${SRC_DIR}/extra

WORKDIR ${BR_ROOT}

RUN sed -e 's/utf8/utf-8/' -i support/dependencies/dependencies.sh && \
    make BR2_EXTERNAL=${SRC_DIR}/extra oldconfig && \
    make --quiet && \
    find output/build -mindepth 2 -not -name '.stamp_*' | xargs rm -rf && \
    rm -rf board/* configs/* dl/* output/images/* output/target/*
