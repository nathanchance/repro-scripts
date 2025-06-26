#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

set kmake \
    kmake \
    ARCH=riscv \
    O=(tbf)-testing \
    mrproper allmodconfig arch/riscv/kernel/vdso/

$kmake (korg_gcc var riscv) &| string match -er '(?:warning|error):'
test "$pipestatus" = "0 1"
or return 125

$kmake (korg_llvm var) &| string match -er PT_DYNAMIC
switch "$pipestatus"
    case '0 0'
        return 1
    case '0 1'
        return 0
end
return 125
