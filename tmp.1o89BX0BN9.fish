#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-bisect
set objfile drivers/net/ethernet/stmicro/stmmac/stmmac_main.o

rm -fr $lnx_bld
mkdir -p $lnx_bld
cp -v $CBL_LKT/configs/alpine/armv7.config $lnx_bld/.config
kmake \
    -C $lnx_src \
    ARCH=arm \
    CCACHE=0 \
    LLVM=1 \
    O=$lnx_bld \
    olddefconfig $objfile; or return 125

llvm-nm $lnx_bld/$objfile &| grep __aeabi_uldivmod
switch "$pipestatus"
    case "0 0"
        return 0 # reverse bisect
    case "0 1"
        return 1 # reverse bisect
    case '*'
        return 125
end
