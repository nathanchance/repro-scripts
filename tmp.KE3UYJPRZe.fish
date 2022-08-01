#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets X86; or return 125

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-testing

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    CCACHE=0 \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    allmodconfig all
