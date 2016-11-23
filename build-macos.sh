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

case $ARCH in
i686)
    FFMPEG_CONFIGURE_FLAGS+=(--cc="gcc -m32")
    ;;
x86_64)
    ;;
*)
    echo "Unknown architecture"
    exit 1
esac

BUILD_DIR=$BASE_DIR/$(mktemp -d build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

OSX_CC=/usr/local/bin/gcc-5
OSX_SDK=/Developer/SDKs/MacOSX10.4u.sdk
OSX_VERSION=10.4

FFMPEG_CONFIGURE_FLAGS+=(
    --prefix=$BASE_DIR/$TARGET
	--enable-cross-compile
	--target-os=darwin
	--arch=$ARCH
	--cc=$OSX_CC
	--enable-memalign-hack
	--extra-ldflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
	--extra-cflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"

perl -pi -e 's{HAVE_MACH_MACH_TIME_H 1}{HAVE_MACH_MACH_TIME_H 0}' config.h

make
make install

chown $(stat -f '%u:%g' $BASE_DIR) -R $BASE_DIR/$TARGET
