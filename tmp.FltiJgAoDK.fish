#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

set kmake \
    kmake \
    ARCH=x86_64 \
    O=$lnx_bld \
    mrproper defconfig arch/x86/entry/vdso/vdso32/sigreturn.o

$kmake (korg_llvm var 16)
or return 125

$kmake (korg_llvm var 15)
