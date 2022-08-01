#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "ARM;X86"; or return 125

set lnx_target arch/arm/nwfpe/softfloat.o

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=arm \
    KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub) \
    LLVM=$llvm_bld/stage1/bin/ \
    O=$lnx_bld \
    allmodconfig $lnx_target; or return

llvm-nm $lnx_bld/$lnx_target &| grep __aeabi_uldivmod
switch "$pipestatus"
    case "0 0"
        return 1
    case "0 1"
        return 0
    case "*"
        return 125
end
