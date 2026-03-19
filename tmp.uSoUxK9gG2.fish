#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux-stable-6.17
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    KCONFIG_ALLCONFIG=(printf 'CONFIG_%s\n' DRM{,_NOUVEAU}=y LTO_CLANG_FULL=y LTO_NONE=n PCI=y | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allnoconfig vmlinux &| tee /tmp/build.log
set kret $pipestatus[1]

string match -er 'PHINode should have one entry for each predecessor of its parent basic block!' </tmp/build.log
switch "$kret $status"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
