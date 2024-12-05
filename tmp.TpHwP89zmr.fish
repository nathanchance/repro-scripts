#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder . \
    --projects clang lld \
    --quiet-cmake \
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper {def,hardening.}config bzImage
or return 125

U=0 kboot -k $lnx_bld -t 30s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
