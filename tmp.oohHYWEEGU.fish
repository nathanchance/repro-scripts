#!/usr/bin/env fish

__in_tree qemu
or return 128

set qemu_bld (tbf)-testing

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)
set lnx_img arch/powerpc/boot/zImage.epapr
if test -z "$lnx_img"
    __print_error "No Linux kernel image set?"
    return 128
end
if not test -e $lnx_bld/$image
    kmake \
        -C $lnx_src \
        ARCH=powerpc \
        (korg_gcc var powerpc64) \
        O=$lnx_bld \
        mrproper powernv_defconfig zImage.epapr
    or return 128
end

qemu_bld=$qemu_bld qemu_src=$PWD cbl_bld_qemu
or return 125

PO=$qemu_bld U=0 kboot \
    -a ppc64le \
    -k $lnx_bld \
    -t 45s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
