#!/usr/bin/env fish

__in_tree llvm
or return 128

cbl_patch_llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
if set -q ret
    return $ret
end

set lnx_src $CBL_SRC_D/linux-next
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=i386 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld
begin
    $kmake mrproper defconfig
    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -e GENERIC_PT \
        -e IOMMU_PT \
        -e IOMMU_PT_AMDV1
    and $kmake olddefconfig drivers/iommu/generic_pt/fmt/iommu_amdv1.o
end
or return 125

llvm-nm $lnx_bld/drivers/iommu/generic_pt/fmt/iommu_amdv1.o | string match -r 'U __udivdi3'
switch "$pipestatus"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
