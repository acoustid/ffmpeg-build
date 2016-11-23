#!/usr/bin/env bash

set -eu

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	curl -O $FFMPEG_TARBALL_URL
fi

: ${ARCH?}

TARGET=ffmpeg-$FFMPEG_VERSION-audio-linux-$ARCH

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

BUILD_DIR=$(mktemp -d -t $(pwd) build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

export CC=/usr/local/bin/gcc-5
export CXX=/usr/bin/g++-5

OSX_SDK=/Developer/SDKs/MacOSX10.4u.sdk
OSX_VERSION=10.4

FFMPEG_CONFIGURE_FLAGS+=(
    --prefix=$BASE_DIR/$TARGET
	--enable-cross-compile
	--target-os=darwin
	--arch=$ARCH
#	--cc=$OSX_CC
	--enable-memalign-hack
	--extra-ldflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
	--extra-cflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
)

mv configure configure.old
grep -v mach_mach_time_h configure.old >configure
chmod +x configure

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"
make
make install

chown $(stat -c '%u:%g' $BASE_DIR) -R $BASE_DIR/$TARGET
