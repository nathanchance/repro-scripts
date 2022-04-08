#!/usr/bin/env fish

set fish_trace 1

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
    --targets "AArch64;ARM;X86"; or exit 125

set lnx $CBL_SRC/linux

PO=$build/stage1/bin kmake \
    -C $lnx \
    ARCH=arm64 \
    LLVM=1 \
    mrproper defconfig all; or exit 125

PO=$build/stage1/bin kmake \
    -C $lnx \
    ARCH=arm64 \
    LLVM=1 \
    mrproper defconfig; or exit 125

$lnx/scripts/config \
    --file $lnx/.config \
    -e LTO_CLANG_THIN

timeout 8m fish -c "kmake \
    -C $lnx \
    ARCH=arm64 \
    LLVM=1 \
    PO=$build/stage1/bin \
    olddefconfig all" &| grep 'Parent == Other->Parent && "cross-BB instruction order comparison"'
switch "$pipestatus"
    case "124 *" "134 0"
        exit 1
    case "0 1"
        exit 0
    case "*"
        exit 125
end
