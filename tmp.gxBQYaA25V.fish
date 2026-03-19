#!/usr/bin/env fish

in_tree llvm
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
    mrproper {def,hardening.}config arch/arm64/kernel/entry.o &| string match -er "Assertion `getContext\(\)\.hadError\(\) \|\| OS\.tell\(\) \- Start == getSectionAddressSize\(\*Sec\)'"
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
