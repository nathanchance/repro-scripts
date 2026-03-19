#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

prep_config $CBL_LKT/configs/archlinux/x86_64.config $lnx_bld
or return 125

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig sound/pci/ens1370.o &| string match -er '"PSet overflow/underflow"'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
