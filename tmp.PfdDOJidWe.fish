#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux-stable-6.15
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld

begin
    $kmake mrproper defconfig sound/pci/hda/snd-hda-codec.o

    and $kmake mrproper defconfig
    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d LTO_NONE \
        -e LTO_CLANG_THIN
end
or return 125

$kmake olddefconfig sound/pci/hda/snd-hda-codec.o &| string match -er 'isa<To>\(Val\) && "cast<Ty>\(\) argument of incompatible type!"'
switch "$pipestatus"
    case '1 0'
        return 1
    case '0 1'
        return 0
end
return 125
