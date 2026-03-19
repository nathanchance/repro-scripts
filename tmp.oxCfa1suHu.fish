#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing
remkdir $lnx_bld

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    defconfig sound/soc/qcom/qdsp6/topology.o &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er "error: '__builtin_counted_by_ref' argument must reference a flexible array member" <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        echo Build succeeded but returning fail for git bisect
        return 1
    case '1 0'
        echo Build failed but returning success for git bisect
        return 0
end
echo Build failed for unexpected reason?
return 125
