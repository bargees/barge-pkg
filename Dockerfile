FROM ailispaw/ubuntu-essential:16.04-nodoc

ENV TERM xterm

RUN apt-get -q update && \
    apt-get -q -y install --no-install-recommends ca-certificates \
      bc build-essential cpio file git python unzip rsync wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup environment
ENV SRC_DIR=/build \
    BR_ROOT=/build/buildroot
RUN mkdir -p ${SRC_DIR}

ENV BR_VERSION 2022.05
RUN wget -qO- https://buildroot.org/downloads/buildroot-${BR_VERSION}.tar.xz | tar xJ && \
    mv buildroot-${BR_VERSION} ${BR_ROOT}

# Apply patches
COPY patches ${SRC_DIR}/patches
RUN for patch in ${SRC_DIR}/patches/*.patch; do \
      patch -p1 -d ${BR_ROOT} < ${patch}; \
    done

# Copy extra packages
COPY extra ${SRC_DIR}/extra

# Copy the empty config file
COPY empty.config ${BR_ROOT}/.config

# Copy the build script file
COPY build.sh ${SRC_DIR}/build.sh

VOLUME ${BR_ROOT}/dl ${BR_ROOT}/ccache

WORKDIR ${BR_ROOT}

CMD ["../build.sh"]
