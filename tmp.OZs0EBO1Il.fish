#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets RISCV (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=riscv \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper defconfig Image
or return 125

kboot -a riscv -k $lnx_bld -t 45s &| string match -er "kmem_cache of name '.*' already exists"
switch "$pipestatus"
    case '0 1'
        return 0
    case '124 0'
        return 1
end
return 125
