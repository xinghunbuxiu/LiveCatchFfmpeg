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
      compgen -G "$DIR/bin/${name}-*.dll" >/dev/null || {
        echo "Missing $name DLL"
        exit 1
      }
    done
    ;;
  macos-arm64|macos-x64)
    required=(libavcodec libavformat libavutil libswresample libswscale)
    for name in "${required[@]}"; do
      compgen -G "$DIR/lib/${name}.*.dylib" >/dev/null || {
        echo "Missing $name dylib"
        exit 1
      }
    done
    ;;
esac

echo "Runtime verification passed: $TARGET"
