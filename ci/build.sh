#! /bin/bash

set -e
set -x

# store repo root as variable
REPO_ROOT=$(readlink -f $(dirname $(dirname $0)))
OLD_CWD=$(readlink -f .)

BUILD_DIR=/tmp/linuxdeploy-build

mkdir -p $BUILD_DIR

pushd "$BUILD_DIR"

EXTRA_CMAKE_ARGS=()

# configure build for AppImage release
cmake "$REPO_ROOT" -DSTATIC_BUILD=On -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo "${EXTRA_CMAKE_ARGS[@]}"

make -j"$(nproc)"

# build patchelf
"$REPO_ROOT"/ci/build-static-patchelf.sh "$(readlink -f out/)"
patchelf_path="$(readlink -f out/usr/bin/patchelf)"

# build custom strip
"$REPO_ROOT"/ci/build-static-binutils.sh "$(readlink -f out/)"
strip_path="$(readlink -f out/usr/bin/strip)"

# use tools we just built for linuxdeploy run
export PATH="$(readlink -f out/usr/bin):$PATH"

# args are used more than once
LINUXDEPLOY_ARGS=("--appdir" "AppDir" "-e" "bin/linuxdeploy" "-i" "$REPO_ROOT/resources/linuxdeploy.png" "-d" "$REPO_ROOT/resources/linuxdeploy.desktop" "-e" "$patchelf_path" "-e" "$strip_path")

# deploy patchelf which is a dependency of linuxdeploy
bin/linuxdeploy "${LINUXDEPLOY_ARGS[@]}"
