#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang llvm{,-unit} \
    --llvm-folder $llvm \
    --projects clang \
    --show-build-commands \
    --targets "AArch64;ARM;X86"; or exit 125

PO=$build/stage1/bin kmake \
    -C $CBL_SRC/common-android-multi/common-4.9 \
    ARCH=arm64 \
    CC=clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    O=.build/arm64 \
    mrproper cuttlefish_defconfig all
