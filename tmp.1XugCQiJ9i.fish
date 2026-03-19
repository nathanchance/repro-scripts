#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_patch_llvm
or return 128

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    KCONFIG_ALLCONFIG=(echo 'CONFIG_COMMON_CLK=y
# CONFIG_LTO_NONE is not set
CONFIG_LTO_CLANG_THIN=y
CONFIG_I2C=y
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_SUPPORT=y
CONFIG_MODULES=y
CONFIG_VIDEO_CAMERA_SENSOR=y
CONFIG_VIDEO_CCS=m
CONFIG_VIDEO_DEV=y' | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allnoconfig drivers/media/i2c/ccs/ccs.o &| string match -er 'drivers/media/i2c/ccs/ccs\.o: warning: objtool: ccs_set_selection\(\): unexpected end of section \.text\.ccs_set_selection'
switch "$pipestatus"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
