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
    --targets "Mips;X86"; or exit 125

set lnx $CBL_SRC/linux-next

PO=$build/stage1/bin kmake \
    -C $lnx \
    ARCH=mips \
    LLVM=1 \
    mrproper malta_defconfig all; or exit 125

kboot \
    -a mipsel \
    -k $lnx \
    -t 45s
