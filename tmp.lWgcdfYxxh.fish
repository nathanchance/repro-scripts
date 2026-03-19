#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=s390 \
    (korg_gcc var s390) \
    O=$lnx_bld \
    mrproper defconfig bzImage
or return 125

kboot \
    -a s390 \
    -k $lnx_bld \
    -t 30s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
