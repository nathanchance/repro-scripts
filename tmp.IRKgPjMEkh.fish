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

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

rm -fr $lnx_bld
mkdir $lnx_bld
crl -o $lnx_bld/.config https://download.01.org/0day-ci/archive/20220915/202209150959.hEWCNjXH-lkp@intel.com/config; or return 125
kmake \
    -C $lnx_src \
    ARCH=i386 \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    olddefconfig all
if test $status -eq 0
    echo "Build succeeded but returning fail for git bisect"
    return 1
else
    echo "Build failed but returning success for git bisect"
    return 0
end
