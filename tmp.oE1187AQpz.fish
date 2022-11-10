#!/usr/bin/env fish

set llvm_src $CBL_WRKTR/llvm-spinlock-bisect
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets X86; or return 125

set lnx_src $CBL_WRKTR/linux-spinlock-bisect
set lnx_bld $TMP_BUILD_FOLDER/linux-bisect
set kmake_args \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld

rm -fr $lnx_bld
kmake $kmake_args defconfig
$lnx_src/scripts/config \
    --file $lnx_bld/.config \
    -e PARAVIRT_SPINLOCKS
kmake $kmake_args olddefconfig kernel/locking/qspinlock.o

# Reverse bisecting
if test $status -eq 0
    return 1
else
    return 0
end
