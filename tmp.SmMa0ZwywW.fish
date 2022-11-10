#!/usr/bin/env fish

set llvm_src $CBL_WRKTR/llvm-project-bisect
set llvm_bld $TMP_BUILD_FOLDER/(basename $llvm_src)

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "ARM;X86"; or return 125

set lnx_src $CBL_WRKTR/linux-next-bisect
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)
set kmake_args \
    -C $lnx_src \
    ARCH=arm \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    mrproper defconfig drivers/pwm/pwm-tegra.o

kmake $kmake_args; or return 125
kmake $kmake_args KCFLAGS=-Werror=shift-overflow
# Reverse bisect
set ret $status
if test $ret -eq 0
    echo "No warning but returning 1 instead of $ret for git bisect"
    return 1
else
    echo "Warning is present but returning 0 instead of $ret for git bisect"
    return 0
end
