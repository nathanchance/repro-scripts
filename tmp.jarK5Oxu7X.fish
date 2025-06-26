#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

if kmake ARCH=i386 (korg_gcc var i386) O=$bld mrproper defconfig bzImage
    kboot -a x86 -k $bld -t 25s
    switch $status
        case 0
            return 0
        case 124
            return 1
    end
end
return 125
