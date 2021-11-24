#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build
set llvm $CBL_SRC/llvm-project

$tc_bld/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets "AArch64;ARM;X86" \
    --show-build-commands; or exit 125

PO=$llvm/build/stage1/bin kmake \
    -C $CBL_SRC/linux-next \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=0 \
    distclean allmodconfig arch/arm64/kvm/hyp/nvhe/hyp-reloc.o; or exit 125

PO=$llvm/build/stage1/bin kmake \
    -C $CBL_SRC/linux-next \
    ARCH=arm64 \
    LLVM=1 \
    distclean allmodconfig arch/arm64/kvm/hyp/nvhe/hyp-reloc.o
# Reverse bisect so bad is good and good is bad
if test $status -eq 0
    exit 1
else
    exit 0
end
