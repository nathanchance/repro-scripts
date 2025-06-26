#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing
set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or return 125

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper defconfig drivers/gpu/drm/i915/i915_vma.o &| string match -er 'N1\.getValueType\(\) == N2\.getValueType\(\) && N1\.getValueType\(\) == VT && "Binary operator types must match!"'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125

set common_bld_llvm_args \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
set kmake \
    kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper defconfig drivers/gpu/drm/i915/i915_vma.o

begin
    cbl_bld_llvm_fast $common_bld_llvm_args

    and $kmake

    and $CBL_GIT/tc-build/build-llvm.py \
        $common_bld_llvm_args \
        --assertions \
        --build-targets distribution \
        --llvm-folder . \
        --projects clang lld \
        --quiet-cmake \
        --show-build-commands
end
or return 125

$kmake &| string match -er 'N1\.getValueType\(\) == N2\.getValueType\(\) && N1\.getValueType\(\) == VT && "Binary operator types must match!"'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
