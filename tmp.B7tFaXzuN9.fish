#!/usr/bin/env fish

in_kernel_tree
or return 128

set lnx_bld (tbf)-bisect

kmake ARCH=arm64 (korg_gcc var arm64) O=$lnx_bld mrproper virtconfig Image.gz
or return 125

U=0 kboot -a arm64 -k $lnx_bld -t 1m &>/tmp/boot.log

switch $status
    case 0
        return 0
    case 124
        if grep "Requesting system poweroff" /tmp/boot.log
            return 1
        else
            return 125
        end
end
return 125
