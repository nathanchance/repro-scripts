#!/usr/bin/env fish

set llvm_build $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_build \
    --build-stage1-only \
    --llvm-folder $CBL_SRC/llvm-project \
    --projects "clang;lld" \
    --targets "AArch64;ARM;X86"; or return 125

set lnx_build $CBL_SRC/common-android-multi/common-mainline/build

rm -fr $lnx_build; or return 125
kmake \
    -C (dirname $lnx_build) \
    ARCH=x86_64 \
    LLVM=$llvm_build/stage1/bin/ \
    O=(basename $lnx_build) \
    gki_defconfig all; or return 125

kboot \
    -a x86_64 \
    -k $lnx_build \
    -t 45s
