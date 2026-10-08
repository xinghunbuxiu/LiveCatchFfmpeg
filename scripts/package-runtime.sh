#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:?usage: package-runtime.sh target}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${FFMPEG_VERSION:-9.0.2}"
SRC="$ROOT/build/runtime/$TARGET"
OUT="$ROOT/dist"
rm -rf "$OUT"; mkdir -p "$OUT"
RUNTIME_STAGE="$OUT/runtime-stage"; SDK_STAGE="$OUT/sdk-stage"
mkdir -p "$RUNTIME_STAGE" "$SDK_STAGE"
case "$TARGET" in
windows-x64)
 cp "$SRC"/bin/*.dll "$RUNTIME_STAGE/"; cp -R "$SRC/manifest" "$RUNTIME_STAGE/"
 cp -R "$SRC/include" "$SDK_STAGE/"; cp -R "$SRC/lib" "$SDK_STAGE/"; cp -R "$SRC/manifest" "$SDK_STAGE/" ;;
macos-arm64|macos-x64)
 cp "$SRC"/lib/*.dylib "$RUNTIME_STAGE/"; cp -R "$SRC/manifest" "$RUNTIME_STAGE/"
 cp -R "$SRC/include" "$SDK_STAGE/"; cp -R "$SRC/lib" "$SDK_STAGE/"; cp -R "$SRC/manifest" "$SDK_STAGE/" ;;
android-arm64)
 mkdir -p "$RUNTIME_STAGE/arm64-v8a"
 cp "$SRC"/lib/*.so "$RUNTIME_STAGE/arm64-v8a/"; cp -R "$SRC/manifest" "$RUNTIME_STAGE/"
 cp -R "$SRC/include" "$SDK_STAGE/"; cp -R "$SRC/lib" "$SDK_STAGE/"; cp -R "$SRC/manifest" "$SDK_STAGE/" ;;
*) echo "Unknown target: $TARGET"; exit 2 ;;
esac
(cd "$RUNTIME_STAGE" && zip -9 -r "$OUT/LiveCatch-ffmpeg-$VERSION-$TARGET.zip" .)
(cd "$SDK_STAGE" && zip -9 -r "$OUT/LiveCatch-ffmpeg-sdk-$VERSION-$TARGET.zip" .)
rm -rf "$RUNTIME_STAGE" "$SDK_STAGE"
