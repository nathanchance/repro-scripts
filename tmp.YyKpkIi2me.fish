#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing
prep_config $CBL_LKT/configs/archlinux/x86_64.config $lnx_bld

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    ARCH=x86_64 \
    (korg_gcc var x86_64) \
    O=$lnx_bld \
    olddefconfig drivers/platform/x86/lenovo/wmi-gamezone.o &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er "warning: 'gz_chain_head' defined but not used \[\-Wunused\-variable\]" <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
