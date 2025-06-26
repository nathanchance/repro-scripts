#!/usr/bin/env fish

in_tree kernel
or return 128

set kmake \
    kmake \
    ARCH=riscv \
    O=(tbf)-testing \
    mrproper allmodconfig lib/kunit/resource.o

$kmake (korg_llvm var 17)
or return 125

$kmake (korg_llvm var 16) &| string match -er 'clang frontend command failed with exit code 139'
switch "$pipestatus"
    case '1 0'
        return 1
    case '0 1'
        return 0
end
return 125
