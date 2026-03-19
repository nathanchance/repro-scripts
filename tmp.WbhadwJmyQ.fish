#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets SystemZ (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux-stable-6.17
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=s390 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper defconfig fs/bcachefs/btree_update.o &| string match -er 'Assertion `!Scope\.isNormalCleanup\(\)'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
