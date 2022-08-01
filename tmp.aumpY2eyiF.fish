#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/linux-next-testing

set ret 0

for compiler in clang gcc
    switch $compiler
        case clang
            set make_args LLVM=1
        case gcc
            set make_args CROSS_COMPILE=aarch64-linux-gnu-
    end

    rm -fr $lnx_bld
    mkdir -p $lnx_bld
    crl -o $lnx_bld/.config https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-aarch64-fedora.config; or return 125

    kmake -C $lnx_src ARCH=arm64 $make_args O=$lnx_bld olddefconfig all
    set ret (math $ret + $status)
end

echo "ret: $ret"

switch $ret
    case 0
        return 0
    case 4
        return 1
    case '*'
        return 125
end
