#!/usr/bin/env fish

in_tree kernel
or return 128

set lnx_bld (tbf)-testing

function build_kernel
    set kmake \
        kmake \
        ARCH=x86_64 \
        KCFLAGS=-Wno-error \
        $argv \
        O=$lnx_bld

    $kmake mrproper defconfig

    and scripts/config \
        --file $lnx_bld/.config \
        -d LTO_NONE \
        -e LTO_CLANG_THIN \
        -e CFI_CLANG

    and $kmake olddefconfig bzImage
end

begin
    build_kernel (korg_llvm var)

    and kboot -k $lnx_bld -t 20s

    and build_kernel LLVM=1
end
or return 125

kboot -k $lnx_bld -t 20s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
