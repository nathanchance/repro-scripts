#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

prep_config https://github.com/ms178/archpkgbuilds/raw/refs/heads/main/packages/linux-cachymod-6.18/config $lnx_bld

timeout 10m kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig vmlinux
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 128
