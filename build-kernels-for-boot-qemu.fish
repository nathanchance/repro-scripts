#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux
set lnx_bld_base $TMP_BUILD_FOLDER/linux-qemu-testing

rm -fr $lnx_bld_base

switch (uname -m)
    case aarch64
        set arches \
            arm32_v7 \
            arm64{,be} \
            x86{,_64}
    case x86_64
        set arches \
            arm32_v{5,6,7} \
            arm64{,be} \
            m68k \
            mips{,el} \
            ppc{32{,_mac},64{,le}} \
            riscv \
            s390 \
            x86{,_64}
end

for arch in $arches
    set -l big_endian false
    set -l kmake_variables
    set -l kmake_targets
    set -l llvm true
    set -l lnx_bld $lnx_bld_base/$arch

    switch $arch
        case arm32_v5
            set -a kmake_variables ARCH=arm
            set -a kmake_targets multi_v5_defconfig zImage aspeed-bmc-opp-palmetto.dtb

        case arm32_v6
            set -a kmake_variables ARCH=arm
            set -a kmake_targets aspeed_g5_defconfig zImage aspeed-bmc-opp-romulus.dtb

        case arm32_v7
            set -a kmake_variables ARCH=arm
            set -a kmake_targets defconfig zImage

        case arm64 arm64be
            set -a kmake_variables ARCH=arm64
            set -a kmake_targets defconfig Image.gz
            if test "$arch" = arm64be
                set big_endian true
            end

        case m68k
            set llvm false
            set -a kmake_variables ARCH=m68k (korg_gcc print 12 m68k)
            set -a kmake_targets mac_defconfig vmlinux

        case mips mipsel
            set -a kmake_variables ARCH=mips
            set -a kmake_targets malta_defconfig vmlinux
            if test "$arch" = mips
                set big_endian true
            end

        case ppc32
            set -a kmake_variables ARCH=powerpc CROSS_COMPILE=powerpc-linux-gnu- LLVM_IAS=0
            set -a kmake_targets ppc44x_defconfig uImage

        case ppc32_mac
            set -a kmake_variables ARCH=powerpc
            set -a kmake_targets pmac32_defconfig vmlinux

        case ppc64
            set -a kmake_variables ARCH=powerpc CROSS_COMPILE=powerpc64-linux-gnu- LD=powerpc64-linux-gnu-ld LLVM_IAS=0
            set -a kmake_targets pseries_defconfig vmlinux

        case ppc64le
            set -a kmake_variables ARCH=powerpc CROSS_COMPILE=powerpc64le-linux-gnu-
            set -a kmake_targets powernv_defconfig zImage.epapr

        case riscv
            set -a kmake_variables ARCH=riscv
            set -a kmake_targets defconfig Image

        case s390
            set -a kmake_variables ARCH=s390 LD=s390x-linux-gnu-ld OBJCOPY=s390x-linux-gnu-objcopy OBJDUMP=s390x-linux-gnu-objdump
            set -a kmake_targets defconfig bzImage

        case x86 x86_64
            if test "$arch" = x86
                set -a kmake_variables ARCH=i386
            else
                set -a kmake_variables ARCH=x86_64
            end
            set -a kmake_targets defconfig bzImage
    end

    if test "$llvm" = true
        set -a kmake_variables LLVM=1
    end

    set -a kmake_variables O=$lnx_bld

    if test "$big_endian" = true
        begin
            kmake -C $lnx_src $kmake_variables $kmake_targets[1]
            and $lnx_src/scripts/config \
                --file $lnx_bld/.config \
                -d CPU_LITTLE_ENDIAN \
                -e CPU_BIG_ENDIAN
            and kmake -C $lnx_src $kmake_variables olddefconfig $kmake_targets[2]
        end; or return
    else
        kmake -C $lnx_src $kmake_variables $kmake_targets; or return
    end
end
