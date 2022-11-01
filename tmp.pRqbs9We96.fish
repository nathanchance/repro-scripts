#!/usr/bin/env fish

set bntls_src $CBL_SRC/binutils-gdb
set bntls_bld $TMP_BUILD_FOLDER/binutils-bisect
set bntls_install $TMP_FOLDER/install/binutils-bisect

if false
rm -fr $bntls_bld $bntls_install

mkdir -p $bntls_bld
cd $bntls_bld; or return 125
$bntls_src/configure \
    CC=gcc \
    CFLAGS=-O2 \
    CXX=g++ \
    CXXFLAGS=-O2 \
    --disable-compressed-debug-sections \
    --disable-gdb \
    --disable-sim \
    --disable-werror \
    --enable-deterministic-archives \
    --enable-lto \
    --enable-new-dtags \
    --enable-plugins \
    --enable-relro \
    --enable-threads \
    --prefix=$bntls_install \
    --quiet \
    --target=riscv64-linux-gnu \
    --with-pic \
    --with-system-zlib

make -sj(nproc) V=0; or return 125
make -sj(nproc) prefix=$bntls_install install; or return 125
end

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-bisect

rm -rf $lnx_bld
mkdir -p $lnx_bld
crl -o $lnx_bld/.config https://github.com/openSUSE/kernel-source/raw/master/config/riscv64/default
$lnx_src/scripts/config \
    --file $lnx_bld/.config \
    -d DEBUG_INFO_DWARF5 \
    -e DEBUG_INFO_DWARF4
PO=$bntls_install/bin kmake \
    -C $lnx_src \
    ARCH=riscv \
    CROSS_COMPILE=riscv64-linux-gnu- \
    LLVM=-12 \
    LLVM_IAS=0 \
    O=$lnx_bld \
    olddefconfig arch/riscv/kernel/vdso/
