#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build

set fish_trace 1

$tc_bld/build-llvm.py \
    --assertions \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --no-update \
    --projects "clang;lld" \
    --targets "RISCV;X86"; or exit 125

PATH="$tc_bld/build/llvm/stage1/bin:$PATH" timeout --foreground 30s \
    make \
    -C $CBL_SRC/linux \
    -skj(nproc) \
    ARCH=riscv \
    LLVM=1 \
    distclean defconfig drivers/gpu/drm/radeon/evergreen.o

set ret $status
if test $ret -eq 0
    exit 0
else if test $ret -eq 124
    exit 1
else
    exit 125
end
