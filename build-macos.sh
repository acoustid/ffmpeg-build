#!/usr/bin/env bash

set -eux

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	curl -O $FFMPEG_TARBALL_URL
fi

: ${ARCH?}

OUTPUT_DIR=ffmpeg-$FFMPEG_VERSION-audio-macos-$ARCH

BUILD_DIR=$BASE_DIR/$(mktemp -d build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

# https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary#Update-the-Architecture-List-of-Custom-Makefiles
case $ARCH in
    x86_64)
        TARGET="x86_64-apple-macos10.8"
        ;;
    arm64)
        TARGET="arm64-apple-macos11"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac


FFMPEG_CONFIGURE_FLAGS+=(
    --cc=/usr/bin/clang
    --prefix=$BASE_DIR/$OUTPUT_DIR
    --enable-cross-compile
    --target-os=darwin
    --arch=$ARCH
    --extra-ldflags="-target $TARGET"
    --extra-cflags="-target $TARGET"
    --enable-runtime-cpudetect
)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}" || (cat ffbuild/config.log && exit 1)

perl -pi -e 's{HAVE_MACH_MACH_TIME_H 1}{HAVE_MACH_MACH_TIME_H 0}' config.h

make V=1
make install

chown -R $(stat -f '%u:%g' $BASE_DIR) $BASE_DIR/$OUTPUT_DIR
