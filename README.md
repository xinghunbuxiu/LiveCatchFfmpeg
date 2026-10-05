# LiveCatch FFmpeg Runtime

This repository builds the minimal FFmpeg runtime used by LiveCatch.

It is intentionally separate from the LiveCatch application source code.

## Targets

- Windows x64
- macOS arm64
- macOS x86_64

## Build profile

- FFmpeg 9.0.2 by default
- LGPL-only profile
- Shared libraries
- No ffmpeg/ffprobe/ffplay programs
- Minimal FLV + H.264/H.265 + AAC playback components
- D3D11VA on Windows
- VideoToolbox on macOS
- HTTP input
- No GPL/nonfree components

## Releases

Push a tag such as:

    ffmpeg-9.0.2-lc1

GitHub Actions builds the supported runtimes and publishes a prerelease containing ZIP packages and SHA256SUMS.txt.

## Important

This is a build-artifact repository for LiveCatch, not a complete FFmpeg distribution. Each runtime records its FFmpeg version, source URL, target and build profile in its manifest.
