#!/usr/bin/env fish

cd $GITHUB_FOLDER/buildall
or return 128

set make_flags -j(nproc)
if not test -x timert
    make $make_flags
    or return 128
end

set prefix (tbf arm64-empty-load-segment)
set gcc_install $prefix/gcc
set binutils_install $prefix/binutils
set gcc_target aarch64
set kernel_target arm64
set cross_compile $gcc_target-linux-

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
EXTRA_BINUTILS_CONF=--disable-gprofng
GCC_SRC=$SRC_FOLDER/gcc
MAKEOPTS=$make_flags"

if not test -e $binutils_install/bin/"$cross_compile"as; or not set -q skip_binutils
    echo "$base_cfg
PREFIX=$binutils_install" >config
    rm -fr $gcc_target
    ./build --binutils $gcc_target
    or set ret 125
end
git -C $binutils_src rh
if set -q ret
    return $ret
end

if not test -e $gcc_install/bin/"$cross_compile"gcc
    echo "$base_cfg
PREFIX=$gcc_install" >config
    rm -fr $gcc_target
    PATH=$binutils_install/bin:$PATH ./build --gcc $gcc_target
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

kmake \
    -C $lnx_src \
    ARCH=$kernel_target \
    CROSS_COMPILE=$combined_install/bin/$cross_compile \
    O=$lnx_bld \
    mrproper tinyconfig vmlinux
or return 125

set output (readelf -lW $lnx_bld/vmlinux | awk '$1 == "LOAD" && $6 ~ /0x0+\>/')
if test (count $output) -ne 0
    printf "\nEmpty load segment found:\n\n%s\n\nbut returning success for git bisect...\n" $output
    return 0
end
printf "\nNo empty load segments found but returning fail for git bisect...\n"
return 1
