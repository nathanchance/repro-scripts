#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --build-targets all \
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing
remkdir $lnx_bld

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    -C $lnx_src \
    -p $llvm_bld/final/bin \
    ARCH=x86_64 \
    LLVM=1 \
    O=$lnx_bld \
    rustavailable &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er 'rustavailable\] Error 1' <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
