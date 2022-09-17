#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=arm64 \
    CROSS_COMPILE=/usr/bin/aarch64-linux-gnu- \
    O=$lnx_bld \
    defconfig Image.gz; or return 125

$CBL_GIT/boot-utils-ro/boot-qemu.py \
    -a arm64 \
    -k $lnx_bld \
    -t 25s; or return

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=riscv \
    CROSS_COMPILE=/usr/bin/riscv64-linux-gnu- \
    O=$lnx_bld \
    defconfig Image; or return 125

$CBL_GIT/boot-utils-ro/boot-qemu.py \
    -a riscv \
    -k $lnx_bld \
    -t 25s; or return
