#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig all &| tee /tmp/build.log
switch $pipestatus[1]
    case 0
        return 0
    case 1
        if grep 'PLEASE submit a bug report to' /tmp/build.log
            return 1
        end
end
return 125
