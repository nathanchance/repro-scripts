#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets X86 \
    --show-build-commands; or exit 125

echo 'register long current_stack_pointer asm("rsp");
void vmcs_set_bits() {
  asm goto("" : "+r"(current_stack_pointer) : : : do_exception);
do_exception:;
}' | $llvm/build/stage1/bin/clang -O2 -c -x c -o /dev/null -
if test "$pipestatus[2]" -eq 0
    exit 0
else
    exit 1
end
