#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

kmake \
    ARCH=i386 \
    (korg_gcc var i386) \
    O=$bld \
    mrproper defconfig bzImage
or return 125

set kboot_args \
    -a x86 \
    -k $bld \
    -t 30s

kboot $kboot_args
or return 125

kboot $kboot_args -m 2G
switch "$pipestatus"
    case 0
        return 0
    case 124
        return 1
end
return 125
