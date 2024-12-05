#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets PowerPC (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc-linux-gnu- \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper pmac32_defconfig all
