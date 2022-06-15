#!/usr/bin/env fish

set build $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --llvm-folder $CBL_SRC/llvm-project \
    --projects "clang;lld" \
    --targets "PowerPC;X86"; or return 125

set lnx $CBL_SRC/linux
set out $TMP_BUILD_FOLDER/linux-bisect
set cfg $out/.config

rm -fr $out
mkdir -p $out

crl -o $cfg https://github.com/openSUSE/kernel-source/raw/master/config/ppc64le/default; or return 125
kmake -C $lnx ARCH=powerpc LLVM=$build/stage1/bin/ O=$out olddefconfig fs/nfs/callback_xdr.o
