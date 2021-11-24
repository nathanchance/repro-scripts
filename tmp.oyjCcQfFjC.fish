#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build

$tc_bld/build-llvm.py \
    --assertions \
    --build-stage1-only \
    --no-update \
    --projects "clang;compiler-rt;lld" \
    --targets X86; or exit 125

PO=$tc_bld/build/llvm/stage1/bin kmake \
    -C $CBL_SRC/kernel-common \
    LLVM=1 \
    V=1 \
    distclean gki_defconfig all &>/tmp/build.log
