#!/usr/bin/env bash

set -eu

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	wget $FFMPEG_TARBALL_URL
fi

: ${ARCH?}

TARGET=ffmpeg-$FFMPEG_VERSION-audio-windows-$ARCH

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

BUILD_DIR=$(mktemp -d -p $(pwd) build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

FFMPEG_CONFIGURE_FLAGS+=(
    --prefix=$BUILD_DIR/install/$TARGET
    --extra-cflags='-static -static-libgcc -static-libstdc++'
    --enable-memalign-hack
    --target-os=mingw32
    --cross-prefix=$ARCH-w64-mingw32-
)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"
make -j 2
make install

cd $BUILD_DIR/install/$TARGET
tar -cf $BASE_DIR/$TARGET.tar.gz .

chown $(stat -c '%u:%g' $BASE_DIR) -R $BASE_DIR/$TARGET.tar.gz
