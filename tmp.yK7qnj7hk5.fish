#!/usr/bin/env fish

set build $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --llvm-folder $CBL_SRC/llvm-project \
    --projects "clang;lld" \
    --targets "AArch64;ARM;X86"; or return 125

tuxmake \
    -a arm64 \
    -C $CBL_SRC/linux \
    -k defconfig \
    -K CONFIG_LTO_CLANG_FULL=y \
    LLVM=$build/stage1/bin/
