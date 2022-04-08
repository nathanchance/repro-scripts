#!/usr/bin/env fish

set qemu_src $CBL_WRKTR/qemu-bisect-arm64-boot-failure
set qemu_bld $qemu_src/build

git -C $qemu_src cl -q
git -C $qemu_src submodule update --init --recursive

mkdir -p $qemu_bld
cd $qemu_bld; or exit 125

$qemu_src/configure --disable-docs --target-list=aarch64-softmmu; or exit 125
make -skj(nproc); or exit 125

PO=$qemu_bld UPDATE=false kboot -a arm64 -k $TMP_FOLDER/build -t 30s
