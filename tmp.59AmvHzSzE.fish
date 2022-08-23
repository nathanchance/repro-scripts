#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-stable-5.10
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

begin
    git -C $lnx_src cl -q
    and rm -fr $lnx_bld
    and mkdir -p $lnx_bld
    and cp -v $CBL_LKT/configs/opensuse/riscv64.config $lnx_bld/.config
    and kmake \
        -C $lnx_src \
        ARCH=riscv \
        CROSS_COMPILE=riscv64-linux-gnu- \
        O=$lnx_bld \
        olddefconfig Image
end; or return 125

kboot -a riscv -k $lnx_bld -t 1m &| grep -F "[    C0] watchdog: BUG: soft lockup - CPU"
switch "$pipestatus"
    case "124 0"
        return 0 # reverse bisect
    case "0 1"
        return 1 # reverse bisect
    case '*'
        return 125
end
