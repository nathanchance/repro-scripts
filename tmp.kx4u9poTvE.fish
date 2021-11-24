#!/usr/bin/env fish

for binary_object in **.o
    file $binary_object | grep -q "LLVM IR bitcode"; or continue
    rm -f test.a
    echo "Testing $binary_object"
    llvm-ar cDPrST test.a $binary_object
    ld.lld -m elf_x86_64 -mllvm -import-instr-limit=5 -r -o /dev/null --whole-archive test.a
end
