#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_patch_llvm
or return 128

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
if set -q ret
    return $ret
end

set lnx_src $CBL_SRC_D/linux-next
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/gpu/drm/xe/xe_ring_ops.o &| tee /tmp/build.log
set krnl_ret $pipestatus[1]

string match -er '"Cannot get layout of forward declarations!"' </tmp/build.log
switch "$krnl_ret $status"
    case '0 1'
        return 0 #1 # reverse bisect
    case '1 0'
        return 1 # 0
end
return 125
