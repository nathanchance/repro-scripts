#!/usr/bin/env fish

in_tree kernel
or return 128

set kmake \
    kmake \
    ARCH=riscv \
    O=(tbf)-testing \
    mrproper defconfig arch/riscv/kernel/compat_vdso/

$kmake (korg_gcc var riscv)
or return 125

$kmake (korg_llvm var)
