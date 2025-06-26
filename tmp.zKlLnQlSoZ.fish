#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

kmake \
    ARCH=loongarch \
    (korg_gcc var loongarch) \
    O=$bld \
    mrproper defconfig vmlinuz.efi
or return 125

kboot \
    -a loongarch \
    -k $bld \
    -t 30s &| string match -er 'BUG: Bad page map in process modprobe'
switch "$pipestatus"
    case '124 0'
        return 1
    case '0 1'
        return 0
end
return 125
