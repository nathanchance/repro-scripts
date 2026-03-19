#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing
prep_config $CBL_LKT/configs/alpine/ppc64le.config $lnx_bld

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    ARCH=powerpc \
    KCFLAGS=-Werror=unknown-attributes \
    (korg_llvm var) \
    O=$lnx_bld \
    olddefconfig lib/vdso/gettimeofday.o &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er "error: unknown attribute 'patchable_function_entry' ignored" <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
