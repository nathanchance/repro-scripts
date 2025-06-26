#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

kmake \
    ARCH=powerpc \
    (korg_gcc var powerpc) \
    O=$bld \
    mrproper pmac32_defconfig vmlinux

and kboot -a ppc32_mac -k $bld -t 90s

and if kmake \
        ARCH=powerpc \
        (korg_llvm var) \
        O=$bld \
        mrproper pmac32_defconfig vmlinux
    kboot -a ppc32_mac -k $bld -t 90s
    switch $status
        case 0
            return 0
        case 124
            return 1
    end
end
return 125
