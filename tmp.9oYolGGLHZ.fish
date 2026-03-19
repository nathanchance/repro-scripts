#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

prep_config $CBL_LKT/configs/debian/powerpc64le.config $lnx_bld

kmake \
    ARCH=powerpc \
    (korg_gcc var powerpc64) \
    O=$lnx_bld \
    olddefconfig zImage.epapr

U=0 kboot -a ppc64le -k $lnx_bld -t 30s
