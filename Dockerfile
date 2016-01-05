FROM ubuntu-debootstrap:14.04.3

ENV TERM xterm

RUN apt-get -q update && \
    apt-get -q -y install ca-certificates \
      bc build-essential python unzip rsync wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup environment
ENV SRC_DIR=/build \
    BR_ROOT=/build/buildroot
RUN mkdir -p ${SRC_DIR}

ENV BR_VERSION 2015.11.1
RUN wget -qO- http://buildroot.uclibc.org/downloads/buildroot-${BR_VERSION}.tar.bz2 | tar xj && \
    mv buildroot-${BR_VERSION} ${BR_ROOT}

# Copy the empty config file
COPY empty.config ${BR_ROOT}/.config

# Copy extra packages
COPY extra ${SRC_DIR}/extra

WORKDIR ${BR_ROOT}

RUN sed -e 's/utf8/utf-8/' -i support/dependencies/dependencies.sh && \
    make BR2_EXTERNAL=${SRC_DIR}/extra oldconfig && \
    make --quiet && \
    rm -rf board/* configs/* dl/* output/images/* output/target/* && \
    find output/build -mindepth 2 -not -name '.stamp_*' | xargs rm -rf
