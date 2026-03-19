#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_patch_llvm

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets RISCV (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set lnx_src $CBL_SRC_C/linux-next
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=riscv \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper defconfig arch/riscv/kernel/vdso/vgettimeofday.o &| string match -er 'arch/riscv/include/asm/vdso/processor.h:\d+:\d+: error: expected instruction format'
switch "$pipestatus"
    case '0 1'
        return 1 # reverse bisect
    case '1 0'
        return 0
end
return 125
