#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_D/linux-next
set lnx_bld (tbf $lnx_src)-testing

set repro_cfg $lnx_src/kernel/configs/repro.config
if not test -f $repro_cfg; or not string match -qr CONFIG_IWLMLD=m <$repro_cfg
    echo 'CONFIG_FORTIFY_SOURCE=y
CONFIG_IWLWIFI=m
CONFIG_IWLMLD=m
CONFIG_UBSAN=y
CONFIG_UBSAN_BOUNDS=y
# CONFIG_UBSAN_SHIFT is not set
# CONFIG_UBSAN_DIV_ZERO is not set
# CONFIG_UBSAN_UNREACHABLE is not set
# CONFIG_UBSAN_INTEGER_WRAP is not set
# CONFIG_UBSAN_BOOL is not set
# CONFIG_UBSAN_ENUM is not set
# CONFIG_UBSAN_ALIGNMENT is not set' >$repro_cfg
end

kmake \
    -C $lnx_src \
    ARCH=arm \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper {def,repro.}config drivers/net/wireless/intel/iwlwifi/mld/d3.o &| string match -r "include/linux/fortify-string.h:719:4: error: call to '__read_overflow' declared with 'error' attribute: detected read beyond size of object \(1st parameter\)"
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
