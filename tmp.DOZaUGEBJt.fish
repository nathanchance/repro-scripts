#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build

set fish_trace 1
$tc_bld/build-llvm.py \
    --assertions \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --no-update \
    --projects "clang;lld" \
    --targets X86; or exit 125
set -e fish_trace

set llvm_bin $tc_bld/build/llvm/stage1/bin
set lnx $CBL_SRC/linux
set cfg $lnx/.config

set kmake_args \
    -C $lnx \
    LLVM=1 \
    LLVM_IAS=1

PO=$llvm_bin kmake $kmake_args distclean defconfig
$lnx/scripts/config --file $cfg -e LTO_CLANG_THIN
PO=$llvm_bin kmake $kmake_args olddefconfig bzImage; or exit 125

bootk -a x86_64 -k $lnx -t 30s
