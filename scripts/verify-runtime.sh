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
android-arm64|android-armv7)
 required=(libavcodec libavformat libavutil libswresample libswscale)
 for name in "${required[@]}"; do find "$DIR/lib" -maxdepth 1 -type f -name "${name}*.so" -print -quit | grep -q . || exit 1; done
 # MediaCodec must be compiled in, not stubbed. A build without
 # --enable-jni turns av_jni_set_java_vm into "return -ENOSYS", after which the
 # player silently decodes on the CPU for every session. Fail the build instead.
 avcodec_so="$(find "$DIR/lib" -maxdepth 1 -type f -name 'libavcodec*.so' -print -quit)"
 avutil_so="$(find "$DIR/lib" -maxdepth 1 -type f -name 'libavutil*.so' -print -quit)"
 for sym in av_jni_set_java_vm av_mediacodec_default_init; do
   nm -D "$avcodec_so" 2>/dev/null | grep -qw "$sym" || {
     echo "ERROR: $sym missing from libavcodec (built without --enable-jni?)" >&2; exit 1; }
 done
 # hwcontext_mediacodec.c registers itself through the internal
 # ff_hwcontext_type_mediacodec symbol, which is hidden from .dynsym. Its own
 # strings are the reliable trace, since that translation unit only gets linked
 # when --enable-mediacodec turned it on.
 strings "$avutil_so" | grep -qx 'mediacodec' || {
   echo "ERROR: mediacodec hwcontext missing from libavutil (--enable-mediacodec?)" >&2; exit 1; }
 # A JNI-less build compiles av_jni_set_java_vm down to "mov w0,#-38; ret".
 # Detect that body so a stubbed JNI cannot pass as working support.
 jni_body="$(objdump -d --no-show-raw-insn "$avcodec_so" 2>/dev/null \
   | awk '/<av_jni_set_java_vm>:/{f=1;next} f&&/^$/{exit} f' | head -3)"
 if printf '%s' "$jni_body" | grep -qE 'mov[[:space:]]+w0, *#-0x26|mov[[:space:]]+w0, *#-38'; then
   echo "ERROR: av_jni_set_java_vm is a -ENOSYS stub; JNI was not enabled" >&2
   exit 1
 fi
 # The decoder itself, not just the wrapper API.
 strings "$avcodec_so" | grep -q '^h264_mediacodec$' || {
   echo "ERROR: h264_mediacodec decoder not compiled into libavcodec" >&2; exit 1; }
 echo "MediaCodec verification passed: $TARGET" ;;
ios-arm64)
 required=(libavcodec libavformat libavutil libswresample libswscale)
 for name in "${required[@]}"; do test -f "$DIR/lib/${name}.a" || exit 1; done ;;
*) echo "Unknown target: $TARGET"; exit 2 ;;
esac
echo "Runtime verification passed: $TARGET"
