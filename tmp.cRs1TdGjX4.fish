#!/usr/bin/env fish

__in_tree kernel
or return 128

test (uname -m) = x86_64
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=x86_64 \
    (korg_gcc var x86_64) \
    O=$lnx_bld \
    mrproper defconfig bzImage
or return 125

U=0 kboot -k $lnx_bld -s 2 -t 30s
or return 125

U=0 kboot -k $lnx_bld -s 1 -t 30s
test $status -eq 0
