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

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig ipc/ipc_sysctl.o &| tee /tmp/build.log
set krnl_ret $pipestatus[1]

string match -er '<inline asm>:\d+:\d+: error: expected newline' </tmp/build.log
switch "$krnl_ret $status"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
