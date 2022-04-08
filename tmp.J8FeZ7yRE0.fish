#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --install-folder $TMP_FOLDER/D122166/(git -C $llvm sha) \
    --install-stage1-only \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --show-build-commands \
    --targets "AArch64;ARM;X86"; or return 125

PO=$build/stage1/bin kmake \
    -C $CBL_SRC/linux \
    ARCH=arm64 \
    LLVM=1 \
    mrproper allmodconfig drivers/scsi/csiostor/csio_lnode.o
