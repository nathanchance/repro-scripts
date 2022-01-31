#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

if false
    $CBL_GIT/tc-build/build-llvm.py \
        --assertions \
        --build-folder $build \
        --build-stage1-only \
        --check-targets clang ll{d,vm{,-unit}} \
        --llvm-folder $llvm \
        --projects "clang;lld" \
        --targets "AArch64;ARM;X86" \
        --show-build-commands; or exit 125
end

cd $CBL_SRC/linux; or exit 125

git cl -q
crl -o .config https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-aarch64-fedora.config; or exit 125
scripts/config -d BPF_PRELOAD

PO="$SRC_FOLDER/pahole/build:$build/stage1/bin" kmake ARCH=arm64 LLVM=1 olddefconfig vmlinux
