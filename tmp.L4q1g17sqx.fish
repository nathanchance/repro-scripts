#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allnoconfig drivers/gpu/drm/amd/amdgpu/../display/dc/dml/dcn32/display_mode_vba_32.o

$kmake KCONFIG_ALLCONFIG=(printf 'CONFIG_%s=y\n' DRM{,_AMD{GPU,_DC}} PCI | psub) &| string match -er "warning: stack frame size \(\d+\) exceeds limit \(2048\) in 'dml32_ModeSupportAndSystemConfigurationFull' \[\-Wframe\-larger\-than\]"
test "$pipestatus" = "0 1"
or return 125

$kmake KCONFIG_ALLCONFIG=(printf 'CONFIG_%s=y\n' DRM{,_AMD{GPU,_DC}} KASAN PCI | psub) &| string match -er "warning: stack frame size \(\d+\) exceeds limit \(3072\) in 'dml32_ModeSupportAndSystemConfigurationFull' \[\-Wframe\-larger\-than\]"
switch "$pipestatus"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
