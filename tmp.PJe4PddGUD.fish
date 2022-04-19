#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --show-build-commands \
    --targets "AArch64;ARM;X86"; or return 125

kmake \
    -C $CBL_SRC/linux \
    ARCH=arm64 \
    LLVM=$build/stage1/bin/ \
    mrproper allnoconfig mm/mmap.o
