#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

# Build LLVM
$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --show-build-commands \
    --targets "PowerPC;X86"; or exit 125

# Build kernel with LLVM
cd $CBL_SRC/linux; or exit 125
git cl -q; or exit 125
crl -o .config https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-ppc64le-fedora.config
PO=$build/stage1/bin kmake \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc64le-linux-gnu- \
    LLVM=1 \
    LLVM_IAS=0 \
    olddefconfig zImage.epapr; or exit 125

# Does kernel boot?
PO=/usr/bin kboot \
    -a ppc64le \
    -t 45s
