#!/usr/bin/env fish

in_tree llvm
or return 128

cbl_patch_llvm
or return 128

set llvm_bld (tbf)-testing

$CBL_GIT/tc-build/build-llvm.py \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder . \
    --projects clang lld \
    --quiet-cmake \
    --show-build-commands \
    --targets RISCV (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set bad_lnx_src $CBL_SRC_C/linux
set good_lnx_src $CBL_SRC_C/linux-stable-6.15

set kmake \
    kmake \
    ARCH=riscv \
    LLVM=$llvm_bld/final/bin/ \
    O=(tbf $bad_lnx_src)-testing \
    mrproper allmodconfig lib/kunit/resource.o

$kmake -C $good_lnx_src
or return 125

$kmake -C $bad_lnx_src &| string match -er 'PLEASE submit a bug report to'
switch "$pipestatus"
    case '0 1'
        echo Build succeeded but returning bad for a reverse git bisect
        return 1
    case '1 0'
        echo Build failed but returning good for a reverse git bisect
        return 0
end
return 125
