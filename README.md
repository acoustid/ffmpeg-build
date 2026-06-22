Static audio-only FFmpeg builds
===============================

This project contains scripts for small static audio-only FFmpeg builds. The
default builds are used for Chromaprint packaging (`fpcalc`), and there is an
additional variant that can also encode audio.

Building is done using GitHub Actions. You can find the built binaries on the
releases page.

The current FFmpeg version is **8.1.2**. The builds are LGPL-licensed (no
`--enable-gpl` or `--enable-nonfree`).

Variants
--------

Each platform is built in two variants, selected with the `FFMPEG_VARIANT`
environment variable:

  - `decode` (default, output label `audio`) — audio **decoders** only, as
    needed by Chromaprint. This is the small, fully self-contained build.
  - `encode` (output label `audio-encode`) — everything in `decode` plus native
    audio **encoders** and muxers for transcoding, including MP3 via a
    statically linked [LAME](https://lame.sourceforge.io/), built from source by
    `build-lame.sh`.

Supported platforms:

  - Linux
      * `x86_64-linux-gnu`
      * `arm64-linux-gnu`
  - Windows
      * `x86_64-w64-mingw32`
      * `i686-w64-mingw32` (32-bit)
  - macOS
      * `x86_64-apple-macos10.9` (macOS Mavericks and newer on Intel CPU)
      * `arm64-apple-macos11` (macOS Big Sur and newer on Apple M1 CPU)

Building locally
----------------

The build scripts read the target architecture and variant from environment
variables, for example:

```sh
ARCH=x86_64 FFMPEG_VARIANT=decode ./build-linux.sh
ARCH=x86_64 FFMPEG_VARIANT=encode ./build-linux.sh
TARGET=arm64-apple-macos11 FFMPEG_VARIANT=encode ./build-macos.sh
```

The resulting tree is placed under `artifacts/`.
