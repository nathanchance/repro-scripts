#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/linux-next-bisect
set cfg $lnx_bld/.config

begin
    rm -fr $lnx_bld
    and mkdir -p $lnx_bld
    and crl -o $cfg https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-aarch64-fedora.config
    and scripts/config --file $cfg --set-val FRAME_WARN 0
    and kmake -C $lnx_src ARCH=arm64 CCACHE=0 LLVM=1 O=$lnx_bld olddefconfig all
end; or return 125

begin
    rm -fr $lnx_bld
    and mkdir -p $lnx_bld
    and crl -o $cfg https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-aarch64-fedora.config
    and scripts/config --file $cfg -d LTO_NONE -e LTO_CLANG_THIN -e CFI_CLANG --set-val FRAME_WARN 0
end; or return 125

kmake -C $lnx_src ARCH=arm64 CCACHE=0 LLVM=1 O=$lnx_bld olddefconfig all
