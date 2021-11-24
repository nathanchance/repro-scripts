#!/usr/bin/env fish

set lnx $CBL_SRC/linux
set cfg $lnx/.config

set kmake_args \
    -C $lnx \
    ARCH=s390 \
    CC=clang \
    CROSS_COMPILE=s390x-linux-gnu- \
    LLVM_IAS=0

PO=$CBL_STOW_LLVM/13.0.0-rc1/bin kmake $kmake_args distclean defconfig
$lnx/scripts/config --file $cfg -e KCSAN -e KCSAN_KUNIT_TEST -e KUNIT
PO=$CBL_STOW_LLVM/13.0.0-rc1/bin kmake $kmake_args olddefconfig bzImage; or exit 125

bootk -a s390 -k $lnx -s 4 -t 4m &| rg " ok " &| rg -v "# test_"
