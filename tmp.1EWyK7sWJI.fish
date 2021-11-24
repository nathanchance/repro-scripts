#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build
set llvm $CBL_SRC/llvm-project

set fish_trace 1

$tc_bld/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets X86 \
    --show-build-commands; or exit 125

set lnx $CBL_SRC/linux-next

git -C $lnx cl -q
crl -o $lnx/.config https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-i686-fedora.config

set -e fish_trace

PO=$llvm/build/stage1/bin kmake \
    -C $lnx \
    ARCH=i386 \
    LLVM=1 \
    olddefconfig arch/x86/platform/efi/efi.o
