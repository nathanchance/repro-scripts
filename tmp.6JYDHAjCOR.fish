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
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

begin
    rm -fr $lnx_bld
    and mkdir -p $lnx_bld
    and crl -o $lnx_bld/.config https://github.com/openSUSE/kernel-source/raw/master/config/x86_64/default
end; or return 125

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    olddefconfig drivers/md/dm-integrity.o
