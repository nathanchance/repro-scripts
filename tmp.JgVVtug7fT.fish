#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build
set llvm $CBL_SRC/llvm-project
set bld_llvm_args \
    --assertions \
    --build-folder $llvm/build \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --no-update \
    --projects "clang;lld" \
    --show-build-commands \
    --targets X86

set fish_trace 1

$tc_bld/build-llvm.py \
    $bld_llvm_args \
    --build-stage1-only; or exit 125

$tc_bld/build-llvm.py \
    $bld_llvm_args \
    --pgo kernel-defconfig
