#!/usr/bin/env fish

# clang 13.0.0 is fine
kmake ARCH=arm LLVM=1 distclean aspeed_g5_defconfig all; or exit 125
kboot -a arm32_v6 -t 30s; or exit 125

# clang 14.0.0 is broken
PO=$CBL_TC_LLVM kmake ARCH=arm LLVM=1 distclean aspeed_g5_defconfig all; or exit 125
kboot -a arm32_v6 -t 30s
