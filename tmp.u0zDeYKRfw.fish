#!/usr/bin/env fish

set llvm_src $CBL_WRKTR/llvm-project-mips32r1-crash
set llvm_bld $TMP_BUILD_FOLDER/llvm-project-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects 'clang;lld' \
    --targets 'Mips;X86'; or return 125

kmake \
    -C $CBL_SRC/linux \
    ARCH=mips \
    CROSS_COMPILE=mips-linux-gnu- \
    LLVM=$llvm_bld/stage1/bin/ \
    LLVM_IAS=0 \
    O=$TMP_BUILD_FOLDER/linux-bisect \
    mrproper 32r1_defconfig all
