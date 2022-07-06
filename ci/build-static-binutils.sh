#! /bin/bash

set -e
set -x

INSTALL_DESTDIR="$1"

BUILD_DIR=/tmp/linuxdeploy-build-binutils

mkdir -p $BUILD_DIR

pushd "$BUILD_DIR"

# fetch source code
wget https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz -O- | tar xJ --strip-components=1

# configure static build
# inspired by https://github.com/andrew-d/static-binaries/blob/master/binutils/build.sh
./configure --prefix=/usr --disable-nls --enable-static-link --disable-shared-plugins --disable-dynamicplugin --disable-tls --disable-pie

# citing the script linked above: "This strange dance is required to get things to be statically linked."
make -j "$(nproc)"
make clean
make -j "$(nproc)" LDFLAGS="-all-static"

# install into user-specified destdir
make install DESTDIR="$(readlink -f "$INSTALL_DESTDIR")"
