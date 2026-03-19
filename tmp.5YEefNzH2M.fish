#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

prep_config $CBL_LKT/configs/alpine/x86_64.config $lnx_bld
set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    ARCH=x86_64 \
    (korg_llvm var) \
    O=$lnx_bld \
    olddefconfig all &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er 'version generation failed, symbol will not be versioned' <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
