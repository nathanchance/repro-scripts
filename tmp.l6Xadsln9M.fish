#!/usr/bin/env fish

set qemu_src $CBL_QEMU_SRC/qemu-bisect
set qemu_bld $qemu_src/.build

set fish_trace 1

rm -rf $qemu_bld
mkdir -p $qemu_bld
cd $qemu_bld; or exit 125

$qemu_src/configure --disable-docs --target-list=arm-softmmu; or exit 125
make -skj(nproc); or exit 125

set -e fish_trace

# GCC needs to boot
PO=$qemu_bld bootk -a arm32_v7 -k $CBL_TMP/qemu-bisect/gcc/zImage -t 30s; or exit 125

# Result of LLVM boot determines pass or fail
PO=$qemu_bld bootk -a arm32_v7 -k $CBL_TMP/qemu-bisect/llvm/zImage -t 30s
