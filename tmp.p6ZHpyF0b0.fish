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
    --targets "AArch64;ARM;X86"; or return

kmake \
    -C $CBL_SRC/linux \
    ARCH=arm64 \
    LLVM=$build/stage1/bin/ \
    mrproper defconfig all; or return

kmake \
    -C $CBL_SRC/linux \
    ARCH=arm64 \
    KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub) \
    LLVM=$build/stage1/bin/ \
    mrproper allmodconfig all
