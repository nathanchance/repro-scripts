#!/usr/bin/env fish

set qemu_src $CBL_QEMU_SRC/qemu-6.1.0
set qemu_bld $qemu_src/.build

set fish_trace 1

rm -rf $qemu_bld
mkdir -p $qemu_bld
cd $qemu_bld; or exit 125

$qemu_src/configure \
    --disable-docs \
    --disable-werror \
    --target-list=x86_64-softmmu; or exit 125
make -skj(nproc); or exit 125

set -e fish_trace

PO=$qemu_bld kboot -a x86_64 -k $CBL_SRC/linux-next -t 30s

set exit $status

if test $exit -eq 0
    exit 0
else if test $exit -eq 124
    exit 1
else
    exit 125
end
