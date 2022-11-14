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

rm -fr $lnx_bld
tuxmake \
    -a arm \
    -b $lnx_bld \
    -C $lnx_src \
    -k multi_v7_defconfig \
    -K CONFIG_THUMB2_KERNEL=y \
    LLVM=$llvm_bld/stage1/bin/ \
    default &| grep -F "warning: '__thumb2__' macro redefined [-Wmacro-redefined]"
switch "$pipestatus"
    case "0 1"
        return 0
    case "0 0"
        return 1
    case "*"
        return 125
end
