# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- `encode` build variant with native audio encoders/muxers and MP3 encoding via
  a statically linked libmp3lame. Selected with `FFMPEG_VARIANT=encode`.
- `arm64-linux-gnu` builds.

### Changed
- Upgraded FFmpeg to 8.1.2.

## [4.2.2-5] - 2020-02-19
### Changed
- Linux and Windows builds now use the manylinux2010 Docker image defined by the Python community.

### Removed
- Removed i686 and armhf builds.

## [4.2.2-4] - 2020-02-12
### Changed
- Enable PIC in static builds

[Unreleased]: https://github.com/acoustid/ffmpeg-build/compare/v4.2.2-5...HEAD
[4.2.2-5]: https://github.com/acoustid/ffmpeg-build/compare/v4.2.2-4...v4.2.2-5
[4.2.2-4]: https://github.com/acoustid/ffmpeg-build/compare/v4.2.2-3...v4.2.2-4
