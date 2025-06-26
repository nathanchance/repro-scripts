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

timeout 1m $PYTHON_SCRIPTS_FOLDER/kmake.py \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc64-linux-gnu- \
    LLVM=$llvm_bld/final/bin/ \
    LLVM_IAS=0 \
    O=$lnx_bld \
    mrproper pmac32_defconfig drivers/md/md.o &| grep -P 'fatal error: error in backend: Found \d+ machine code errors'
switch "$pipestatus"
    case '1 0' '124 *'
        return 1
    case '0 1'
        return 0
end
return 125
