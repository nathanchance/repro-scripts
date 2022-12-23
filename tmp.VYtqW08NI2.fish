#!/usr/bin/env fish

set lnx_src $CBL_WRKTR/linux-next-powerpc-bisect
set lnx_bld $TMP_BUILD_FOLDER/linux-next-bisect

begin
    rm -fr $lnx_bld
    and mkdir -p $lnx_bld
    and crl -o $lnx_bld/.config https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-ppc64le-fedora.config
    and kmake \
        -C $lnx_src \
        ARCH=powerpc \
        CROSS_COMPILE=$CBL_TC_STOW_GCC/10.4.0/bin/powerpc64-linux- \
        O=$lnx_bld olddefconfig zImage.epapr
end; or return 124

U=0 kboot -a ppc64le -k $lnx_bld -t 1m
