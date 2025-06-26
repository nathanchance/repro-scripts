#!/usr/bin/env fish

in_tree kernel
or return 128

set kmake \
    kmake \
    ARCH=loongarch \
    (korg_llvm var) \
    O=(tbf)-testing \
    mrproper allmodconfig arch/loongarch/kernel/head.o

$kmake CROSS_COMPILE=loongarch64-linux-gnu- LLVM_IAS=0
or return 125

$kmake
