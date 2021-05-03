#!/usr/bin/env bash

# FFMPEG_VERSION=4.4
# FFMPEG_TARBALL=ffmpeg-$FFMPEG_VERSION.tar.bz2
# FFMPEG_TARBALL_URL=http://ffmpeg.org/releases/$FFMPEG_TARBALL

FFMPEG_CONFIGURE_FLAGS=(
    --enable-nonfree 
    --enable-gpl 
    --enable-libx264 
    --enable-libfdk-aac 
    --enable-libx264 
    --enable-static
    --enable-pic
    --disable-ffplay 
    --disable-ffprobe
    --disable-shared
    --enable-ffmpeg

    # --disable-doc
    # # --disable-debug
    # --disable-avdevice
    # --disable-swscale
    # --disable-programs
    
    
    # --disable-videotoolbox
    # --disable-audiotoolbox

    # --disable-filters

    # --disable-protocols
)
