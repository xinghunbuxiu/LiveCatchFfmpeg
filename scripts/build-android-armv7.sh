#!/usr/bin/env bash
# Build minimal LiveCatch FFmpeg shared runtime for Android armeabi-v7a.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${FFMPEG_VERSION:-9.0.2}"
API="${ANDROID_API_LEVEL:-24}"
NDK="${ANDROID_NDK_HOME:?ANDROID_NDK_HOME is required}"

# CI uses linux-x86_64; macOS local builds use darwin-x86_64 (or darwin-arm64).
PREBUILT=""
for host in linux-x86_64 darwin-arm64 darwin-x86_64; do
  if [[ -d "$NDK/toolchains/llvm/prebuilt/$host" ]]; then
    PREBUILT="$host"
    break
  fi
done
test -n "$PREBUILT"
TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/$PREBUILT"
TARGET="android-armv7"
PREFIX="$ROOT/build/runtime/$TARGET"
SRC="$ROOT/build/src/ffmpeg-$VERSION"
ARCHIVE="$ROOT/build/src/ffmpeg-$VERSION.tar.xz"
URL="https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.xz"
CC="$TOOLCHAIN/bin/armv7a-linux-androideabi${API}-clang"
CXX="$TOOLCHAIN/bin/armv7a-linux-androideabi${API}-clang++"
AR="$TOOLCHAIN/bin/llvm-ar"
RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
STRIP="$TOOLCHAIN/bin/llvm-strip"
test -x "$CC"
test -x "$CXX"
mkdir -p "$ROOT/build/src" "$PREFIX"
if [[ ! -f "$ARCHIVE" ]]; then curl -fL --retry 3 -o "$ARCHIVE" "$URL"; fi
if [[ ! -d "$SRC" ]]; then tar -xf "$ARCHIVE" -C "$ROOT/build/src"; fi
cd "$SRC"
make distclean >/dev/null 2>&1 || true
./configure \
  --prefix="$PREFIX" \
  --target-os=android \
  --arch=arm \
  --cpu=armv7-a \
  --enable-neon \
  --cc="$CC" \
  --cxx="$CXX" \
  --ar="$AR" \
  --ranlib="$RANLIB" \
  --strip="$STRIP" \
  --enable-cross-compile \
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
  --enable-network \
  --enable-protocol=file \
  --enable-protocol=http \
  --enable-demuxer=flv \
  --enable-decoder=h264 \
  --enable-decoder=hevc \
  --enable-decoder=aac \
  --enable-parser=h264 \
  --enable-parser=hevc \
  --enable-parser=aac \
  --enable-swscale \
  --enable-swresample \
  --extra-cflags="-fPIC -mfpu=neon" \
  --extra-ldflags="-Wl,-z,max-page-size=16384"
JOBS="$(sysctl -n hw.ncpu 2>/dev/null || nproc)"
make -j"$JOBS"
make install
mkdir -p "$PREFIX/manifest"
cat > "$PREFIX/manifest/build.txt" <<EOF
FFmpeg: $VERSION
License profile: LGPL
Target: android-armv7
ABI: armeabi-v7a
Android API: $API
Source: $URL
Configure: minimal LiveCatch playback runtime
EOF
