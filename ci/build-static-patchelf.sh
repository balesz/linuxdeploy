#! /bin/bash

set -e
set -x

INSTALL_DESTDIR="$1"

BUILD_DIR=/tmp/linuxdeploy-build-patchelf

mkdir -p $BUILD_DIR

pushd "$BUILD_DIR"

# fetch source code
git clone https://github.com/NixOS/patchelf.git .

# cannot use -b since it's not supported in really old versions of git
git checkout 0.8

# prepare configure script
./bootstrap.sh

# configure static build
env LDFLAGS="-static -static-libgcc -static-libstdc++" ./configure --prefix=/usr

# build binary
make -j "$(nproc)"

# install into user-specified destdir
make install DESTDIR="$INSTALL_DESTDIR"
