#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build

set fish_trace 1

# rm -rf $llvm_bin

$tc_bld/build-llvm.py \
    --assertions \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --install-folder $TMP_FOLDER/llvm-85b4b21c8bbad346d58a30154d2767c39cf3285a-assertions \
    --install-stage1-only \
    --no-ccache \
    --no-update \
    --projects "clang;lld;polly" \
    --show-build-commands \
    --targets X86; or exit 125

$tc_bld/build-llvm.py \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --install-folder $TMP_FOLDER/llvm-85b4b21c8bbad346d58a30154d2767c39cf3285a \
    --install-stage1-only \
    --no-ccache \
    --no-update \
    --projects "clang;lld;polly" \
    --show-build-commands \
    --targets X86; or exit 125

exit 0

set lnx $CBL_SRC/linux-stable-5.14

git -C $lnx cl -q

crl -o $lnx/.config https://github.com/ClangBuiltLinux/linux/files/7197432/config.txt

set -e fish_trace

NO_CCACHE=true PO=$llvm_bin kmake -C $lnx LLVM=1 LLVM_IAS=1 KCFLAGS="-mllvm -polly -mllvm -polly-invariant-load-hoisting" olddefconfig all
