#!/usr/bin/env fish

in_kernel_tree
or return 128

kmake ARCH=loongarch (korg_gcc var loongarch) mrproper defconfig vmlinuz.efi
or return 125

kboot -a loongarch -t 30s
switch "$status"
    case 0
        return 0
    case 124
        return 1
    case '*'
        return 125
end
