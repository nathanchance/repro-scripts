#!/usr/bin/env fish

set -l llvm $CBL_WRKTR/llvm-cbl-1523
set -l build $llvm/build

podcmd $CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang llvm{,-unit} \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects clang \
    --targets '"AArch64;X86"' \
    --show-build-commands; or exit 125

set clang $build/stage1/bin/clang --target=aarch64-linux-gnu
set io_flags -c -o /dev/null $CBL/creduce-files/cbl-1523/test.i

podcmd $clang -fpatchable-function-entry=2 -O1 $io_flags; or exit 125
podcmd $clang -fpatchable-function-entry=2 -Os $io_flags; or exit 125
podcmd $clang -Oz $io_flags; or exit 125

podcmd $clang -fpatchable-function-entry=2 -Oz $io_flags &| grep "Assertion `Symbol' failed"
set my_pipe $pipestatus
if test $my_pipe[1] -eq 0
    exit 0
else
    if test $my_pipe[2] -eq 0
        exit 1
    else
        exit 125
    end
end
