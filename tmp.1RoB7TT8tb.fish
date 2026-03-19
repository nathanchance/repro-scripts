#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets LoongArch (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=loongarch \
    KCONFIG_ALLCONFIG=(printf 'CONFIG_%s\n' FTRACE=n GCOV_KERNEL=n LTO_CLANG_THIN=y WERROR=n | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/media/usb/go7007/s2250.o &| string match -er "Assertion `!NodePtr\->isKnownSentinel\(\)'"
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
