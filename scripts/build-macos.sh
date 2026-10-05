#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${FFMPEG_VERSION:-9.0.2}"
ARCH="${1:?usage: build-macos.sh arm64|x86_64}"
PREFIX="$ROOT/build/runtime/macos-$ARCH"
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

./configure \
  --prefix="$PREFIX" \
  --arch="$ARCH" \
  --enable-shared \
  --disable-static \
  --disable-programs \
  --disable-doc \
  --disable-debug \
  --disable-autodetect \
  --disable-everything \
  --disable-gpl \
  --disable-nonfree \
  --disable-avdevice \
  --enable-videotoolbox \
  --enable-protocol=file \
  --enable-protocol=http \
  --enable-demuxer=flv \
  --enable-decoder=h264 \
  --enable-decoder=hevc \
  --enable-decoder=aac \
  --enable-parser=h264 \
  --enable-parser=hevc \
  --enable-parser=aac \
  --enable-hwaccel=h264_videotoolbox \
  --enable-hwaccel=hevc_videotoolbox \
  --enable-swscale \
  --enable-swresample

make -j"$(sysctl -n hw.ncpu)"
make install

mkdir -p "$PREFIX/manifest"
cat > "$PREFIX/manifest/build.txt" <<EOF
FFmpeg: $VERSION
License profile: LGPL
Target: macos-$ARCH
Source: $URL
Configure: minimal LiveCatch playback runtime
EOF
