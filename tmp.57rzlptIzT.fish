#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=arm \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    (korg_llvm var) \
    O=$lnx_bld \
    mrproper allmodconfig drivers/gpu/drm/amd/amdgpu/
or return 125

llvm-nm $lnx_bld/drivers/gpu/drm/amd/ras/ras_mgr/amdgpu_ras_mgr.o &| string match -er __aeabi_uldivmod
switch "$pipestatus"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
