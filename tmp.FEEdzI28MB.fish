#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --show-build-commands \
    --targets "AArch64;ARM;X86"; or return 125

cbl_lkt \
    --arches arm32,arm64 \
    --linux-src $CBL_SRC/linux-next \
    --llvm-prefix $build/stage1
