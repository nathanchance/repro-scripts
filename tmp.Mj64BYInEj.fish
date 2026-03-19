#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets PowerPC (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=powerpc \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper ppc64e_defconfig arch/powerpc/kernel/vdso/vgetrandom-32.o &| string match -er 'N1\.getValueType\(\) == N2\.getValueType\(\) && N1\.getValueType\(\) == VT && "Binary operator types must match!"'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
