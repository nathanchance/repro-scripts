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

prep_config $CBL_LKT/configs/archlinux/x86_64.config $lnx_bld

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig drivers/gpu/drm/radeon/radeon.o &| string match -er 'drivers/gpu/drm/radeon/radeon\.o: warning: objtool: radeon_bo_list_validate\+0x[[:xdigit:]]+: __stack_chk_fail\(\) missing __noreturn in \.c/\.h or NORETURN\(\) in noreturns\.h'
switch "$pipestatus"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
