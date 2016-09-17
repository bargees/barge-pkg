FROM ailispaw/ubuntu-essential:14.04-nodoc

ENV TERM xterm

RUN apt-get -q update && \
    apt-get -q -y install --no-install-recommends ca-certificates \
      bc build-essential bsdmainutils cpio file git python unzip rsync wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup environment
ENV SRC_DIR=/build \
    BR_ROOT=/build/buildroot
RUN mkdir -p ${SRC_DIR}

ENV BR_VERSION 2016.08.1
RUN wget -qO- https://buildroot.org/downloads/buildroot-${BR_VERSION}.tar.bz2 | tar xj && \
    mv buildroot-${BR_VERSION} ${BR_ROOT}

# Apply patches
COPY patches ${SRC_DIR}/patches
RUN for patch in ${SRC_DIR}/patches/*.patch; do \
      patch -p1 -d ${BR_ROOT} < ${patch}; \
    done

# Copy the empty config file
COPY empty.config ${BR_ROOT}/.config

# Copy extra packages
COPY extra ${SRC_DIR}/extra

WORKDIR ${BR_ROOT}

RUN sed -e 's/utf8/utf-8/' -i support/dependencies/dependencies.sh && \
    make BR2_EXTERNAL=${SRC_DIR}/extra oldconfig && \
    make --quiet && \
    find output/build -mindepth 2 -not -name '.stamp_*' | xargs rm -rf && \
    find output/target/ -name 'libstdc++.so*' | tar zcf ${SRC_DIR}/libstdcxx.tar.gz --transform 's?output/target?.?g' -T - && \
    rm -rf board/* configs/* dl/* output/images/* output/target/* ccache/*
