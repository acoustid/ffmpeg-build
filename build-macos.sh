#!/usr/bin/env bash
source ~/workdir/ffmpeg-build/common.sh
# TARGET="/Applications/Gramrphone.app/Contents/FFMPEG/"
ARCH=x86_64
OSX_SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk
OSX_VERSION=10.13

FFMPEG_CONFIGURE_FLAGS+=(
	# --prefix=$TARGET
	--enable-cross-compile
	--target-os=darwin
	--arch=$ARCH
	--extra-ldflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
	--extra-cflags="-isysroot $OSX_SDK -mmacosx-version-min=$OSX_VERSION -arch $ARCH"
)
echo "${FFMPEG_CONFIGURE_FLAGS[@]}"

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"

perl -pi -e 's{HAVE_MACH_MACH_TIME_H 1}{HAVE_MACH_MACH_TIME_H 0}' config.h

make
# make install

# chown -R $(stat -f '%u:%g' $BASE_DIR) $BASE_DIR/$TARGET
