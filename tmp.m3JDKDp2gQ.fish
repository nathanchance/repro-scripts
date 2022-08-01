#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "ARM;X86"; or return 125

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-testing

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=arm \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    multi_v5_defconfig net/mac80211/he.o &| grep Waddress-of-packed-member
switch "$pipestatus"
    case "0 0"
        return 1
    case "0 1"
        return 0
    case "*"
        return 125
end
