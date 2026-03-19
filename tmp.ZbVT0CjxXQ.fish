#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing
remkdir $lnx_bld

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    ARCH=hexagon \
    KCONFIG_ALLCONFIG=(begin; echo CONFIG_TRIM_UNUSED_KSYMS=n; print_no_werror_cfgs; end | psub) \
    (korg_llvm var 19) \
    O=$lnx_bld \
    mrproper allmodconfig vmlinux
or return 125

kmake \
    ARCH=hexagon \
    KCONFIG_ALLCONFIG=(begin; echo CONFIG_TRIM_UNUSED_KSYMS=n; print_no_werror_cfgs; end | psub) \
    (korg_llvm var 18) \
    O=$lnx_bld \
    mrproper allmodconfig vmlinux &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er "ld\.lld: error: vmlinux\.a\(arch/hexagon/kernel/head\.o\):\(\.init\.text\+0x[0-9a-f]+\): relocation R_HEX_B22_PCREL out of range: \d+ is not in \[\-\d+, \d+\]; references 'memset'" <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
