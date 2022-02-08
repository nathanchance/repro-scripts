#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets "AArch64;ARM;X86" \
    --show-build-commands; or exit 125

set lnx $TMP_FOLDER/msm-4.14

git -C $lnx cl -q

if test (count $argv) -eq 0
    set make_targets vendor/violet-perf_defconfig all
else
    set make_targets $argv
end

PO=$build/stage1/bin kmake \
    -C $lnx \
    AR=llvm-ar \
    ARCH=arm64 \
    CC=clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LD=ld.lld \
    NM=llvm-nm \
    O=build \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    $make_targets
