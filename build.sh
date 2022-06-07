#!/bin/bash
set -e

make BR2_EXTERNAL=${SRC_DIR}/extra oldconfig
make --quiet

# Make the libstdcxx package
find output/target/ -name 'libstdc++.so*' | tar zcf ${SRC_DIR}/libstdcxx.tar.gz --transform 's?output/target?.?g' -T -

# Clean intermediate objects
find output/build -mindepth 2 -not -name '.stamp_*' | xargs rm -rf
rm -rf board/* configs/* output/images/* output/target/*
