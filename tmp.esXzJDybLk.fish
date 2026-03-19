#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=mips \
    (korg_gcc var mips) \
    O=$lnx_bld \
    mrproper malta_defconfig vmlinux
or return 125

kboot -a mipsel -k $lnx_bld -t 30s
