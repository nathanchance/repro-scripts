#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_build $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_build \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "AArch64;ARM;X86"; or return 125

set lnx_src $CBL_SRC/linux-next
set lnx_build $TMP_BUILD_FOLDER/(basename $lnx_src)

rm -fr $lnx_build
kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_build/stage1/bin/ \
    O=$lnx_build \
    defconfig arch/arm64/kernel/vdso32/

if test "$status" = 0
    echo "Build succeeded but returning fail for git bisect"
    return 1
else
    echo "Build failed but returning success for git bisect"
    return 0
end
