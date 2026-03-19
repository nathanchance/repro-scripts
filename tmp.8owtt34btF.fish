#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --check-targets clang lld llvm llvm-unit \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_D/linux
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=arm \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig all

$kmake KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub)
or return

$kmake KCONFIG_ALLCONFIG=(begin; print_no_werror_cfgs; printf 'CONFIG_%s\n' ARCH_MULTI_V6=n THUMB2_KERNEL=y; end | psub)
