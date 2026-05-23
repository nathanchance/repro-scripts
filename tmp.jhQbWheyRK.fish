#!/usr/bin/env fish

if test $UTS_MACH != x86_64
    __print_error "Test must be run on an x86_64 machine"
    return 128
end

set prefix $TMP_FOLDER/cbl-2162

set make \
    make -j(nproc) -O

set binutils_src $CBL_SRC_D/binutils
set binutils_install $prefix/install/binutils
set binutils_build $prefix/build/binutils

if not test -e $binutils_install/bin/as
    remkdircd $binutils_build

    $binutils_src/configure \
        --disable-gdb \
        --disable-gdbserver \
        --disable-libdecnumber \
        --disable-nls \
        --disable-readline \
        --disable-sim \
        --disable-werror \
        --enable-default-execstack=no \
        --enable-deterministic-archives \
        --enable-gold \
        --enable-install-libiberty \
        --enable-ld=default \
        --enable-new-dtags \
        --enable-relro \
        --enable-shared \
        --enable-targets=x86_64-pep \
        --enable-threads \
        --prefix=$binutils_install \
        --with-pic \
        --with-system-zlib

    and $make
    and $make install
end
or return 128

set gcc_src $SRC_FOLDER/gcc
set gcc_install $prefix/install/gcc
set gcc_build $prefix/build/gcc

remkdir $gcc_install
remkdircd $gcc_build

begin
    $gcc_src/configure \
        --disable-bootstrap \
        --disable-fixincludes \
        --disable-libssp \
        --disable-libstdcxx-pch \
        --disable-werror \
        --enable-checking=release \
        --enable-clocale=gnu \
        --enable-default-pie \
        --enable-default-ssp \
        --enable-gnu-indirect-function \
        --enable-gnu-unique-object \
        --enable-languages=c,c++ \
        --enable-libstdcxx-backtrace \
        --enable-link-serialization=1 \
        --enable-linker-build-id \
        --enable-lto \
        --enable-multilib \
        --enable-plugin \
        --enable-shared \
        --enable-threads=posix \
        --prefix=$gcc_install \
        --with-system-zlib \
        --without-headers

    and PATH=$binutils_install/bin:$PATH $make

    and PATH=$binutils_install/bin:$PATH $make install
end
or return 125

set gnu_install $prefix/install/gnu
begin
    remkdir $gnu_install
    and cp -R $binutils_install/* $gnu_install
    and cp -R $gcc_install/* $gnu_install
end
or return 125

set llvm_src $CBL_SRC_D/llvm-project
set llvm_bld $prefix/build/llvm

PATH=$gnu_install/bin:$PATH \
    CC=$gnu_install/bin/gcc \
    CXX=$gnu_install/bin/g++ \
    cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --llvm-folder $llvm_src
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld $prefix/build/linux

for i in (seq 0 9)
    prep_config https://github.com/user-attachments/files/27516248/kernel.config.txt $lnx_bld

    $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d DEBUG_INFO_DWARF5 \
        -e DEBUG_INFO_NONE \
        -u MODULE_SIG_KEY

    set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

    kmake \
        --no-ccache \
        -C $lnx_src \
        ARCH=x86_64 \
        LLVM=$llvm_bld/final/bin/ \
        O=$lnx_bld \
        olddefconfig drivers/bus/mhi/host/mhi.o &| tee $lnx_bld_log
    set krnl_ret $pipestatus[1]

    string match -er 'bad \.discard\.annotate_insn entry' <$lnx_bld_log
    set strm_ret $status

    switch "$krnl_ret $strm_ret"
        case '0 1'
            continue
        case '1 0'
            return 1
        case '*'
            return 128
    end
end
return 0
