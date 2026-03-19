#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets RISCV (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_D/linux
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    $PYTHON_SCRIPTS_FOLDER/kmake.py \
    -C $lnx_src \
    ARCH=riscv \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld

begin
    $kmake mrproper defconfig

    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d LTO_NONE \
        -e LTO_CLANG_THIN

    and $kmake olddefconfig
end
or return 125

timeout 15s $kmake arch/riscv/purgatory/
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
