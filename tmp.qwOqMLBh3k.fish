#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing
rm -fr $llvm_bld

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --build-targets clang \
    --projects clang \
    --targets (get_host_llvm_target)
or return 125

$llvm_bld/final/bin/clang --version | head -1 | string match -er '^ClangBuiltLinux clang'
test "$pipestatus" = "0 0 0"
