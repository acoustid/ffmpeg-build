#!/usr/bin/env bash

set -eu

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	curl -s -L -O $FFMPEG_TARBALL_URL
fi

: ${ARCH?}

OUTPUT_DIR=artifacts/ffmpeg-$FFMPEG_VERSION-$FFMPEG_VARIANT_LABEL-$ARCH-w64-mingw32

BUILD_DIR=$(mktemp -d -p $(pwd) build.XXXXXXXX)
DEPS_DIR=$(mktemp -d -p $(pwd) deps.XXXXXXXX)
trap 'rm -rf $BUILD_DIR $DEPS_DIR' EXIT

if [ "$FFMPEG_VARIANT" = encode ]
then
    LAME_PREFIX=$DEPS_DIR ./build-lame.sh --host=$ARCH-w64-mingw32
    FFMPEG_CONFIGURE_FLAGS+=(
        --extra-cflags=-I$DEPS_DIR/include
        --extra-ldflags=-L$DEPS_DIR/lib
    )
fi

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

FFMPEG_CONFIGURE_FLAGS+=(
    --prefix=$BASE_DIR/$OUTPUT_DIR
    --extra-cflags='-static -static-libgcc -static-libstdc++'
    --target-os=mingw32
    --arch=$ARCH
    --cross-prefix=$ARCH-w64-mingw32-
)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"
make
make install

chown $(stat -c '%u:%g' $BASE_DIR) -R $BASE_DIR/$OUTPUT_DIR
