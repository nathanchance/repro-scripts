#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/(basename $llvm_src)-testing

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "ARM;X86"; or return 125

set lnx_src $CBL_SRC/linux-stable-5.4
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-testing

cbl_lkt \
    --architectures arm \
    --build-folder $lnx_bld \
    --linux-folder $lnx_src \
    --llvm-prefix $llvm_bld/stage1
