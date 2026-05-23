#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

prep_config $CBL_LKT/configs/archlinux/x86_64.config $lnx_bld

scripts/config \
    --file $lnx_bld/.config \
    -d LTO_NONE \
    -e LTO_CLANG_THIN

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    ARCH=x86_64 \
    (korg_llvm var) \
    O=$lnx_bld \
    olddefconfig vmlinux &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er 'vmlinux\.o: warning: objtool: irqentry_exit\+0x[0-9a-f]+: call to cpu_to_node\(\) with UACCESS enabled' <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
