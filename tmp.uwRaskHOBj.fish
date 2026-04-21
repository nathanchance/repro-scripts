#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing
prep_config $CBL_LKT/configs/alpine/armv7.config $lnx_bld

kmake \
    ARCH=arm \
    (korg_gcc var arm) \
    O=$lnx_bld \
    olddefconfig zImage
or return 125

kboot \
    -a arm \
    -k $lnx_bld \
    -t 45s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
