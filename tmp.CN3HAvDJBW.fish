#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper multi_v5_defconfig drivers/tty/sysrq.o
