FROM ubuntu:14.04.3

ENV TERM xterm

RUN apt-get update && \
    apt-get install -y ca-certificates curl git && \
    apt-get install -y unzip bc wget python xz-utils build-essential libncurses5-dev && \
    apt-get install -y syslinux xorriso dosfstools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup Buildroot
ENV SRCDIR /build
RUN mkdir -p ${SRCDIR}

ENV BUILDROOT_VERSION 2015.11.1
ENV BUILDROOT ${SRCDIR}/buildroot
RUN cd ${SRCDIR} && \
    curl -OL http://buildroot.uclibc.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.bz2 && \
    tar xf buildroot-${BUILDROOT_VERSION}.tar.bz2 && \
    mv buildroot-${BUILDROOT_VERSION} buildroot && \
    rm -f buildroot-${BUILDROOT_VERSION}.tar.bz2

# Copy the empty config file
COPY empty.config ${BUILDROOT}/.config

# Copy extra packages
COPY package ${BUILDROOT}/package/

WORKDIR ${BUILDROOT}

RUN sed -e 's/utf8/utf-8/' -i support/dependencies/dependencies.sh && \
    make oldconfig && \
    make --quiet && \
    rm -rf board/* configs/* dl/* && \
    find output/build -mindepth 2 -not -name '.stamp_*' | xargs rm -rf
