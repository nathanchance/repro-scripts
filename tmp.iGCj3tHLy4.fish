#!/usr/bin/env fish

in_kernel_tree
or return 128

set lnx_bld (tbf)-bisect

prep_config $CBL_LKT/configs/archlinux/x86_64.config $lnx_bld
or return 128

kmake \
    ARCH=x86_64 \
    LLVM=1 \
    O=$lnx_bld \
    olddefconfig bzImage

kboot \
    -a x86_64 \
    -k $lnx_bld \
    -t 30s
