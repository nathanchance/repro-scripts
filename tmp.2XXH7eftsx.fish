#!/usr/bin/env fish

if test -z "$container"
    print_error "This should be run in a container!"
    exit 130
end

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets "Mips;X86" \
    --show-build-commands; or exit 125

PO=$build/stage1/bin kmake \
    -C $CBL_SRC/linux-next \
    ARCH=mips \
    CROSS_COMPILE=mips64-linux-gnu- \
    LLVM=1 \
    LLVM_IAS=0 \
    distclean loongson3_defconfig arch/mips/
