#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=loongarch \
    (korg_llvm var) \
    O=$lnx_bld \
    mrproper defconfig vmlinuz.efi
or return 125

kboot -a loongarch -k $lnx_bld -t 30s &| string match -er 'ACPI Error:'
switch "$pipestatus"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
