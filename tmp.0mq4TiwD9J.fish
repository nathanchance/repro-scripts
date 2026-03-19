#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=sparc \
    (korg_gcc var sparc64) \
    O=$lnx_bld \
    mrproper sparc64_defconfig image
or return 125

kboot \
    -a sparc64 \
    -k $lnx_bld \
    -t 30s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
