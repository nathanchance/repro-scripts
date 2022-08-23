#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "RISCV;X86"; or return 125

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=riscv \
    KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub) \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    allmodconfig init/
