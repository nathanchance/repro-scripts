#!/usr/bin/env fish

__in_container_msg -c
or return

set rpm_src $SRC_FOLDER/rpm
set rpm_bld (tbf $rpm_src)-testing

remkdir $rpm_bld

cmake \
    -B $rpm_bld \
    -S $rpm_src \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DENABLE_TESTSUITE=OFF \
    -DRPM_VENDOR=redhat
or return

cmake --build $rpm_bld
or return

run0 cmake --install $rpm_bld
or return

rpmbuild --version
or return

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)
rm -fr $lnx_bld_log

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    (korg_gcc var x86_64) \
    O=$lnx_bld

if not test -e $lnx_bld/vmlinux
    $kmake mrproper defconfig

    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d DEBUG_INFO_NONE \
        -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT

    and $kmake olddefconfig all
end
or return

set rpmtmp /tmp/rpmtmp
remkdir $rpmtmp

$kmake RPMOPTS="--define '_tmppath $rpmtmp'" binrpm-pkg &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

string match -er 'error: Installed \(but unpackaged\) file\(s\) found:' <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        echo "rpm build successfully but returning fail for reverse git bisect"
        return 1
    case '1 0'
        echo "rpm failed to bbuild but returning success for reverse git bisect"
        return 0
end
return 125
