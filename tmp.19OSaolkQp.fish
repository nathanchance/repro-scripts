#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects clang \
    --show-build-commands \
    --targets X86; or exit 125

set clang $build/stage1/bin/clang
set io_flags -c -x c - -o /dev/null

echo "__attribute__((nocf_check)) int ibt_save();
void uv_bios_call() {
  { ibt_save(); };
  uv_bios_call();
}" | $clang $io_flags; or exit 125

echo "__attribute__((nocf_check)) int ibt_save();
void uv_bios_call() {
  { ibt_save(); };
  uv_bios_call();
}" | $clang -fcf-protection=branch $io_flags

# Reverse bisect
if test $status -eq 0
    exit 1
else
    exit 0
end
