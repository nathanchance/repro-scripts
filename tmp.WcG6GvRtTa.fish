#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --build-folder $build \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects clang \
    --targets X86; or return 125

kmake \
    -C $CBL_SRC/linux \
    ARCH=i386 \
    CC=$build/stage1/bin/clang \
    PO=$CBL_TMP/1617/binutils-2.38/bin \
    mrproper defconfig all &| command rg "access beyond end of merged section"
switch "$pipestatus"
    case "0 1"
        exit 0
    case "0 0"
        exit 1
    case "*"
        exit 125
end
