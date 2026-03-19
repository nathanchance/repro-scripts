#!/usr/bin/env fish

cd $GITHUB_FOLDER/buildall
or return 128

set make_flags -j(nproc)
if not test -x timert
    make $make_flags
    or return 128
end

set prefix (tbf s390-modinfo-bisect)
set gcc_install $prefix/gcc
set binutils_install $prefix/binutils

set binutils_src $CBL_SRC_D/binutils
begin
    if not test -d $binutils_src/readline/readline
        set old_readline true
        git -C $binutils_src rm -fr readline
    end
    and git -C $binutils_src checkout origin/master -- readline/readline
    and if set -q old_readline
        git -C $binutils_src mv (string replace $binutils_src/ '' $binutils_src/readline/readline/{*,.*}) readline
        and rmdir $binutils_src/readline/readline
        and sed -i 's;\.\./\.\.;..;g' $binutils_src/readline/configure
    end
end
or return 125

set base_cfg "BINUTILS_SRC=$CBL_SRC_D/binutils
CHECKING=release
ECHO=/bin/echo
GCC_SRC=$SRC_FOLDER/gcc
MAKEOPTS=$make_flags"

if not test -e $binutils_install/bin/s390-linux-as; or not set -q skip_binutils
    echo "$base_cfg
    PREFIX=$binutils_install" >config
    rm -fr s390
    ./build --binutils s390
    or set ret 125
end
git -C $binutils_src rh
if set -q ret
    return $ret
end

if not test -e $gcc_install/bin/s390-linux-gcc
    echo "$base_cfg
PREFIX=$gcc_install" >config
    rm -fr s390
    PATH=$binutils_install/bin:$PATH ./build --gcc s390
    or return 125
end

set combined_install $prefix/combined
begin
    remkdir $combined_install
    and cp -R $binutils_install/* $combined_install
    and cp -R $gcc_install/* $combined_install
end
or return 125

if not set -q lnx_src
    set lnx_src $CBL_SRC_C/linux
end
set lnx_bld (tbf $lnx_src)-bisect

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=s390 \
    CROSS_COMPILE=$combined_install/bin/s390-linux- \
    O=$lnx_bld

$kmake mrproper defconfig
or return 125

$lnx_src/scripts/config \
    --file $lnx_bld/.config \
    -d DEBUG_INFO_DWARF4 \
    -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT

$kmake olddefconfig all &| tee /tmp/build.log
if test $pipestatus[1] -ne 0
    return 125
end

# reverse bisect so presence of the warning is good (exit code 0)
string match -er "warning: allocated section `\.got\.plt' not in segment" </tmp/build.log
