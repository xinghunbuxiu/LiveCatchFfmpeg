#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${FFMPEG_VERSION:-9.0.2}"
MIN_IOS="${IOS_DEPLOYMENT_TARGET:-13.0}"
TARGET="ios-arm64"
PREFIX="$ROOT/build/runtime/$TARGET"
SRC="$ROOT/build/src/ffmpeg-$VERSION"
ARCHIVE="$ROOT/build/src/ffmpeg-$VERSION.tar.xz"
URL="https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.xz"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
CC="$(xcrun --sdk iphoneos --find clang)"
AR="$(xcrun --sdk iphoneos --find ar)"
RANLIB="$(xcrun --sdk iphoneos --find ranlib)"
STRIP="$(xcrun --sdk iphoneos --find strip)"
mkdir -p "$ROOT/build/src" "$PREFIX"
if [[ ! -f "$ARCHIVE" ]]; then curl -fL --retry 3 -o "$ARCHIVE" "$URL"; fi
if [[ ! -d "$SRC" ]]; then tar -xf "$ARCHIVE" -C "$ROOT/build/src"; fi
cd "$SRC"
make distclean >/dev/null 2>&1 || true
./configure --prefix="$PREFIX" --target-os=darwin --arch=aarch64 --cpu=armv8-a --cc="$CC" --ar="$AR" --ranlib="$RANLIB" --strip="$STRIP" --enable-cross-compile --sysroot="$SDK" --enable-static --disable-shared --disable-programs --disable-doc --disable-debug --disable-autodetect --disable-everything --disable-gpl --disable-nonfree --disable-avdevice --enable-network --enable-protocol=file --enable-protocol=http --enable-demuxer=flv --enable-decoder=h264 --enable-decoder=hevc --enable-decoder=aac --enable-parser=h264 --enable-parser=hevc --enable-parser=aac --enable-swscale --enable-swresample --extra-cflags="-arch arm64 -mios-version-min=$MIN_IOS -fPIC -isysroot $SDK" --extra-ldflags="-arch arm64 -mios-version-min=$MIN_IOS -isysroot $SDK"
make -j"$(sysctl -n hw.ncpu)"
make install
mkdir -p "$PREFIX/manifest"
cat > "$PREFIX/manifest/build.txt" <<EOF
FFmpeg: $VERSION
License profile: LGPL
Target: ios-arm64 (device)
iOS deployment target: $MIN_IOS
SDK: iphoneos
Source: $URL
Configure: minimal LiveCatch playback runtime; static libraries
EOF
