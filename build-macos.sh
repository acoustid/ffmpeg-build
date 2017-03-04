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

OSX_SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk
OSX_VERSION=10.6

FFMPEG_CONFIGURE_FLAGS+=(
    --prefix=$BASE_DIR/$TARGET
	--enable-cross-compile
	--target-os=darwin
	--arch=$ARCH
	--enable-memalign-hack
	--extra-ldflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
	--extra-cflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"

perl -pi -e 's{HAVE_MACH_MACH_TIME_H 1}{HAVE_MACH_MACH_TIME_H 0}' config.h

make
make install

chown -R $(stat -f '%u:%g' $BASE_DIR) $BASE_DIR/$TARGET
