#!/usr/bin/env fish

set build $TMP_BUILD_FOLDER/llvm

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $CBL_SRC/llvm-project \
    --projects "clang;lld" \
    --targets X86; or return 125

kmake \
    -C $CBL_SRC/linux-stable-5.17 \
    KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub) \
    LLVM=1 \
    PO=$build/stage1/bin/ \
    mrproper allmodconfig security/tomoyo/load_policy.o
