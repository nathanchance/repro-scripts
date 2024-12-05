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
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_D/linux-next
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper {def,hardening.,overflow_kunit.}config Image.gz
or return 125

U=0 kboot -k $lnx_bld -t 30s &| grep 'not ok 22 DEFINE_FLEX_test'
switch "$pipestatus"
    case "0 1"
        return 0
    case "0 0"
        return 1
end
return 125
