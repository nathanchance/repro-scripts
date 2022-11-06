#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "AArch64;ARM;X86"; or return 125

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-bisect

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    allmodconfig drivers/block/drbd/drbd_state.o
