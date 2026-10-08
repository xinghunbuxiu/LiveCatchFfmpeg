#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:?usage: verify-runtime.sh target}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/build/runtime/$TARGET"
test -d "$DIR"
case "$TARGET" in
windows-x64)
 required=(avcodec avformat avutil swresample swscale)
 for name in "${required[@]}"; do find "$DIR/bin" -maxdepth 1 -type f -name "${name}-*.dll" -print -quit | grep -q . || exit 1; done ;;
macos-arm64|macos-x64)
 required=(libavcodec libavformat libavutil libswresample libswscale)
 for name in "${required[@]}"; do find "$DIR/lib" -maxdepth 1 -type f -name "${name}*.dylib" -print -quit | grep -q . || exit 1; done ;;
android-arm64)
 required=(libavcodec libavformat libavutil libswresample libswscale)
 for name in "${required[@]}"; do find "$DIR/lib" -maxdepth 1 -type f -name "${name}*.so" -print -quit | grep -q . || exit 1; done ;;
esac
echo "Runtime verification passed: $TARGET"
