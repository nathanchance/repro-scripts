#!/usr/bin/env fish

set lnx $CBL_SRC/linux-next

kmake \
    -C $lnx \
    ARCH=arm \
    CROSS_COMPILE=arm-none-eabi- \
    mrproper aspeed_g5_defconfig all; or return 125

$CBL_GIT/boot-utils/boot-qemu.sh \
    -a arm32_v6 \
    -k $CBL_SRC/linux-next \
    -t 12s # &| rg -F -- '---[ end trace '
#if test "$pipestatus" = "0 0"
#    exit 1
#else
#    exit 0
#end
