#!/usr/bin/env fish

set qemu_src $CBL_QEMU_SRC/qemu-bisect
set qemu_bld $qemu_src/.build

set fish_trace 1

rm -fr $qemu_bld
mkdir -p $qemu_bld
cd $qemu_bld; or exit 125

git -C $qemu_src submodule update \
    --init \
    --recursive; or exit 125
sed -i /LDFLAGS_NOPIE/d $qemu_src/configure
sed -i 's; $(LDFLAGS_NOPIE) ; ;g' $qemu_src/pc-bios/optionrom/Makefile

if $qemu_src/configure \
        --disable-{docs,werror} \
        --enable-pie \
        --target-list=aarch64-softmmu
    if not make -skj(nproc)
        git -C $qemu_src rh
        exit 125
    end
else
    git -C $qemu_src rh
    exit 125
end

git -C $qemu_src rh

set qemu_path (dirname (fd -t x qemu-system-aarch64 $qemu_bld))

set -e fish_trace

PATH="$qemu_path:$PATH" kboot -a arm64be -k $CBL_SRC/linux-stable-4.14 -t 30s

set exit $status

if test $exit -ne 0
    exit 125
end

PATH="$qemu_path:$PATH" kboot -a arm64be -k $CBL_SRC/linux-stable-4.9 -t 30s

set exit $status

if test $exit -eq 0
    exit 0
else if test $exit -eq 124
    exit 1
else
    exit 125
end
