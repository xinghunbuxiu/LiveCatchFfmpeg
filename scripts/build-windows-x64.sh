#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${FFMPEG_VERSION:-9.0.2}"
PREFIX="$ROOT/build/runtime/windows-x64"
SRC="$ROOT/build/src/ffmpeg-$VERSION"
ARCHIVE="$ROOT/build/src/ffmpeg-$VERSION.tar.xz"
URL="https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.xz"

mkdir -p "$ROOT/build/src" "$PREFIX"

if [[ ! -f "$ARCHIVE" ]]; then
  curl -fL --retry 3 -o "$ARCHIVE" "$URL"
fi

if [[ ! -d "$SRC" ]]; then
  tar -xf "$ARCHIVE" -C "$ROOT/build/src"
fi

cd "$SRC"

./configure   --prefix="$PREFIX"   --target-os=mingw32   --arch=x86_64   --cross-prefix="${TARGET:-x86_64-w64-mingw32}-"   --enable-cross-compile   --enable-shared   --disable-static   --disable-programs   --disable-doc   --disable-debug   --disable-autodetect   --disable-everything   --disable-gpl   --disable-nonfree   --disable-postproc   --disable-avdevice   --enable-protocol=file   --enable-protocol=http   --enable-demuxer=flv   --enable-decoder=h264   --enable-decoder=hevc   --enable-decoder=aac   --enable-parser=h264   --enable-parser=hevc   --enable-parser=aac   --enable-hwaccel=h264_d3d11va   --enable-hwaccel=hevc_d3d11va   --enable-swscale   --enable-swresample

make -j"$(nproc)"
make install

mkdir -p "$PREFIX/manifest"
cat > "$PREFIX/manifest/build.txt" <<EOF
FFmpeg: $VERSION
License profile: LGPL
Target: windows-x64
Source: $URL
Configure: minimal LiveCatch playback runtime
EOF
