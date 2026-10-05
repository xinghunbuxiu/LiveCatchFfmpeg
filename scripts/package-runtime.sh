#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:?usage: package-runtime.sh target}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${FFMPEG_VERSION:-9.0.2}"
SRC="$ROOT/build/runtime/$TARGET"
OUT="$ROOT/dist"

rm -rf "$OUT"
mkdir -p "$OUT"

case "$TARGET" in
  windows-x64)
    mkdir -p "$OUT/stage"
    cp "$SRC"/bin/*.dll "$OUT/stage/"
    cp -R "$SRC/manifest" "$OUT/stage/"
    (cd "$OUT/stage" && zip -9 -r "$OUT/LiveCatch-ffmpeg-$VERSION-$TARGET.zip" .)
    ;;
  macos-arm64|macos-x64)
    mkdir -p "$OUT/stage"
    cp "$SRC"/lib/*.dylib "$OUT/stage/"
    cp -R "$SRC/manifest" "$OUT/stage/"
    (cd "$OUT/stage" && zip -9 -r "$OUT/LiveCatch-ffmpeg-$VERSION-$TARGET.zip" .)
    ;;
  *)
    echo "Unknown target: $TARGET"
    exit 2
    ;;
esac

rm -rf "$OUT/stage"
