#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:?usage: verify-runtime.sh windows-x64|macos-arm64|macos-x64}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/build/runtime/$TARGET"

test -d "$DIR"

case "$TARGET" in
  windows-x64)
    required=(avcodec avformat avutil swresample swscale)
    for name in "${required[@]}"; do
      if ! find "$DIR/bin" -maxdepth 1 -type f -name "${name}-*.dll" -print -quit | grep -q .; then
        echo "Missing $name DLL"
        find "$DIR/bin" -maxdepth 1 -type f -print 2>/dev/null || true
        exit 1
      fi
    done
    ;;
  macos-arm64|macos-x64)
    required=(libavcodec libavformat libavutil libswresample libswscale)
    for name in "${required[@]}"; do
      if ! find "$DIR/lib" -maxdepth 1 -type f -name "${name}*.dylib" -print -quit | grep -q .; then
        echo "Missing $name dylib"
        find "$DIR/lib" -maxdepth 1 -print 2>/dev/null || true
        exit 1
      fi
    done
    ;;
esac

echo "Runtime verification passed: $TARGET"
