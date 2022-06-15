#!/usr/bin/env fish

set build $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --llvm-folder $CBL_SRC/llvm-project \
    --projects "clang;lld" \
    --targets X86; or return 125

kmake \
    -C $CBL_SRC/linux-stable-5.18 \
    ARCH=x86_64 \
    KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub) \
    LLVM=$build/stage1/bin/ \
    mrproper allmodconfig all &| grep "error: write on a pipe with no reader"

set ret $pipestatus
if test $ret[1] -eq 0
    if test $ret[2] -eq 0
        return 1
    else
        return 0
    end
else
    return 125
end
