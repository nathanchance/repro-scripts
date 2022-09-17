#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-testing

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets X86; or return 125

cbl_bld_lnx_dbg -z LLVM=$llvm_bld/stage1/bin/
