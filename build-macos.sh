#!/usr/bin/env bash

set -eux

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	curl -s -L -O $FFMPEG_TARBALL_URL
fi

: ${TARGET?}

case $TARGET in
    x86_64-*)
        ARCH="x86_64"
        LAME_HOST_ARCH="x86_64"
        ;;
    arm64-*)
        ARCH="arm64"
        # LAME 3.100's config.sub predates Apple silicon and knows aarch64,
        # not arm64, so use that for the --host triple.
        LAME_HOST_ARCH="aarch64"
        ;;
    *)
        echo "Unknown target: $TARGET"
        exit 1
        ;;
esac

OUTPUT_DIR=artifacts/ffmpeg-$FFMPEG_VERSION-$FFMPEG_VARIANT_LABEL-$TARGET

BUILD_DIR=$BASE_DIR/$(mktemp -d build.XXXXXXXX)
DEPS_DIR=$BASE_DIR/$(mktemp -d deps.XXXXXXXX)
trap 'rm -rf $BUILD_DIR $DEPS_DIR' EXIT

if [ "$FFMPEG_VARIANT" = encode ]
then
    LAME_PREFIX=$DEPS_DIR ./build-lame.sh \
        --host=$LAME_HOST_ARCH-apple-darwin \
        "CC=/usr/bin/clang -target $TARGET" \
        "CFLAGS=-fPIC -target $TARGET"
    FFMPEG_CONFIGURE_FLAGS+=(
        --extra-cflags=-I$DEPS_DIR/include
        --extra-ldflags=-L$DEPS_DIR/lib
    )
fi

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

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
