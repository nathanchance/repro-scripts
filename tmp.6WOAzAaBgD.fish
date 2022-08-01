#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc-linux-gnu- \
    O=$lnx_bld \
    ppc44x_defconfig all; or return 125

rm -fr $lnx_bld
kmake \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc-linux-gnu- \
    LLVM=$CBL_TC_STOW_LLVM/2022-07-26_19-10-35-1cbaf681b0f1e7257e7e2a63d290a20216668f17/bin/ \
    LLVM_IAS=0 \
    O=$lnx_bld \
    ppc44x_defconfig all &| grep "error: undefined symbol: __umoddi3"
switch "$pipestatus"
    case "2 0"
        return 1
    case "0 1"
        return 0
    case "*"
        return 125
end
