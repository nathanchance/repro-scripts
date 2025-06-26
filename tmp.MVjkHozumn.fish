#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

kmake \
    ARCH=x86_64 \
    (korg_gcc var x86_64) \
    O=$bld \
    mrproper defconfig bzImage
or return 125

U=0 kboot -k $bld &| grep 'workqueue: work disable count underflowed'
set ret $pipestatus
switch "$ret"
    case '0 0'
        return 1
    case '0 1'
        return 0
end
return 125
