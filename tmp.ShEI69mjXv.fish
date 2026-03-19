#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

set kmake \
    kmake \
    ARCH=riscv \
    O=$lnx_bld \
    mrproper allmodconfig vmlinux

$kmake KCONFIG_ALLCONFIG=(printf 'CONFIG_%s\n' GCOV_KERNEL=n LTO_CLANG_THIN=y TRIM_UNUSED_KSYMS=n WERROR=n | psub) (korg_llvm var)
or return 125

$kmake KCONFIG_ALLCONFIG=(printf 'CONFIG_%s\n' GCOV_KERNEL=n LTO_CLANG_THIN=y TRIM_UNUSED_KSYMS=n WERROR=n | psub) LLVM=1 &| string match -er 'Assertion `j \+ 2 == skip'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
