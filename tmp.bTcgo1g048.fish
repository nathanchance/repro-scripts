#!/usr/bin/env fish

set qemu_src $CBL_QEMU_SRC/qemu-bisect
set qemu_bld $qemu_src/build

git -C $qemu_src cl -q
git -C $qemu_src submodule update --init --recursive

mkdir -p $qemu_bld
cd $qemu_bld; or exit 125

$qemu_src/configure --disable-{docs,werror} --target-list=s390x-softmmu; or exit 125
make -skj(nproc); or exit 125

PATH=$qemu_bld:$PATH $CBL_GIT/boot-utils/boot-qemu.py -a s390 -k $CBL_SRC/linux -t 30s
