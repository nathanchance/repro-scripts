#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=arm \
    (korg_gcc var arm) \
    O=$lnx_bld \
    mrproper defconfig zImage
or return 125

U=0 kboot -a arm -k $lnx_bld -t 15s &>/tmp/boot.log
set kboot_ret $status
string match -er '8<--- cut here ---' </tmp/boot.log | uniq
switch "$kboot_ret $pipestatus[1]"
    case '0 1'
        return 0
    case '124 0'
        return 1
end
return 125
