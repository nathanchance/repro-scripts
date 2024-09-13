#!/usr/bin/env fish

in_kernel_tree
or return 128

set bld (tbf)-bisect

prep_config $CBL_LKT/configs/debian/armmp.config $bld
or return 125

kmake \
    ARCH=arm \
    (korg_llvm var) \
    O=$bld \
    olddefconfig zImage
or return 125

kboot \
    -a arm \
    -k $bld \
    -t 30s | grep -F 'at lib/string_helpers.c'
switch "$pipestatus"
    case "0 1"
        return 0
    case "124 0"
        return 1
end
return 125
