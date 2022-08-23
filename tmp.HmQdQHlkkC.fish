#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/linux-next-bisect
set ret 0

for compiler in gcc llvm
    set -l kmake_args
    if test $compiler = llvm
        set -a kmake_args LLVM=1
    end

    begin
        rm -fr $lnx_bld
        and mkdir -p $lnx_bld
        and crl -o $lnx_bld/.config https://github.com/openSUSE/kernel-source/raw/master/config/ppc64le/default
    end; or return 125

    kmake \
        -C $lnx_src \
        ARCH=powerpc \
        CROSS_COMPILE=powerpc64le-linux-gnu- \
        $kmake_args \
        O=$lnx_bld \
        olddefconfig all
    set ret (math $ret + $status)
end

switch $ret
    case 0
        return 0
    case 4
        return 1
    case '*'
        return 125
end
