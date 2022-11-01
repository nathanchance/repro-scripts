#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

set kmake_args \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=1 \
    O=$lnx_bld

kmake $kmake_args mrproper defconfig arch/arm64/kernel/module-plts.o; or return 125

begin
    kmake $kmake_args mrproper defconfig
    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d LTO_NONE \
        -e LTO_CLANG_THIN
    and kmake $kmake_args olddefconfig
end; or return 125

kmake $kmake_args arch/arm64/kernel/module-plts.o
