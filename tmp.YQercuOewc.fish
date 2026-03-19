#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

prep_config $CBL_LKT/configs/fedora/aarch64.config $lnx_bld

kmake \
    ARCH=arm64 \
    (korg_gcc var arm64) \
    O=$lnx_bld \
    olddefconfig Image.gz
or return 125

kboot -a arm64 -k $lnx_bld -m 2G -t 30s
