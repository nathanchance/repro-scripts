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

set -p PATH $llvm/build/stage1/bin

cd $CBL/creduce-files/tsan-crash; or exit 125

# Smoke test without LTO
clang -fshort-wchar -O2 -fno-stack-protector -c -o core.{o,i} &>/dev/null; or exit 125
clang -fshort-wchar -O2 -fsanitize=thread -c -o timekeeping.{o,i} &>/dev/null; or exit 125

# No debug info
clang -fshort-wchar -O2 -flto -fno-stack-protector -c -o core.{o,i} &>/dev/null; or exit 125
clang -fshort-wchar -O2 -flto -fsanitize=thread -c -o timekeeping.{o,i} &>/dev/null; or exit 125

llvm-ar cDPrST built-in.a {core,timekeeping}.o; or exit 125

ld.lld -m elf_x86_64 -r -o /dev/null --whole-archive built-in.a &| grep "inlinable function call in a function with debug info must have a"
set my_pipe $pipestatus
if test $my_pipe[1] -ne 0
    exit 125
else if test $my_pipe[2] -eq 0
    exit 125
end

# With debug info
clang -fshort-wchar -O2 -flto -g -fno-stack-protector -c -o core.{o,i} &>/dev/null; or exit 125
clang -fshort-wchar -O2 -flto -g -fsanitize=thread -c -o timekeeping.{o,i} &>/dev/null; or exit 125

llvm-ar cDPrST built-in.a {core,timekeeping}.o; or exit 125

ld.lld -m elf_x86_64 -r -o /dev/null --whole-archive built-in.a &| grep "inlinable function call in a function with debug info must have a"
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
