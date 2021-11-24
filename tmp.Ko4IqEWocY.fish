#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets X86 \
    --show-build-commands; or exit 125

set tmp_file (mktemp --suffix=.log)
PO=$llvm/build/stage1/bin kmake \
    -C $CBL_SRC/linux \
    KCONFIG_ALLCONFIG=1 \
    LLVM=1 \
    LLVM_IAS=1 \
    V=1 \
    distclean allmodconfig all &>$tmp_file
# If the kernel build failed, the revision is untestable
if test $status -ne 0
    exit 125
end

grep "unexpected end of section" $tmp_file
# The string being present means the revision is bad
if test $status -eq 0
    exit 1
else
    exit 0
end
