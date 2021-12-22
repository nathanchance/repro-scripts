#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project

podcmd $CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects '"clang;lld"' \
    --targets X86 \
    --show-build-commands
