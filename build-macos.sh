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

TARGET=ffmpeg-$FFMPEG_VERSION-audio-macos-$ARCH

BUILD_DIR=$BASE_DIR/$(mktemp -d build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

EXTRA_CFLAGS=""
EXTRA_LDFLAGS=""

case $ARCH in
    x86_64)
        EXTRA_CFLAGS="-mmacosx-version-min=10.6 -arch=$ARCH"
        EXTRA_LDFLAGS="-mmacosx-version-min=10.6 -arch=$ARCH"
        ;;
    arm64)
        EXTRA_CFLAGS="-target arm64-apple-macos11 -mmacosx-version-min=11.0 -arch=$ARCH"
        EXTRA_LDFLAGS="-target arm64-apple-macos11 -mmacosx-version-min=11.0 -arch=$ARCH"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac


FFMPEG_CONFIGURE_FLAGS+=(
    --cc=/usr/bin/clang
	--prefix=$BASE_DIR/$TARGET
	--enable-cross-compile
	--target-os=darwin
	--arch=$ARCH
	--extra-ldflags="$EXTRA_LDFLAGS"
    --extra-cflags="$EXTRA_CFLAGS"
    --enable-runtime-cpudetect
)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}" || (cat ffbuild/config.log && exit 1)

perl -pi -e 's{HAVE_MACH_MACH_TIME_H 1}{HAVE_MACH_MACH_TIME_H 0}' config.h

make V=1
make install

chown -R $(stat -f '%u:%g' $BASE_DIR) $BASE_DIR/$TARGET
