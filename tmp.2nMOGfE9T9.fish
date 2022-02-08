#!/usr/bin/env fish

in_kernel_tree; or exit

for arg in $argv
    switch $arg
        case -g --gcc
            set gcc true
        case -l --localmodconfig
            set localmodconfig true
        case -m --menuconfig
            set menuconfig true
    end
end

if test "$gcc" != true
    set kmake_args LLVM=1
end

set pkg linux-debug
set pkgroot $ENV_FOLDER/pkgbuilds/$pkg
set pkgdir $pkgroot/pkg-fish/$pkg

rm -fr $pkgroot/pkg{,-fish} $pkgroot/*.tar.zst

git cl -q

scripts/setlocalversion --save-scmversion
echo -debug >localversion.10-pkgname

crl -o .config https://github.com/archlinux/svntogit-packages/raw/packages/linux/trunk/config; or exit
scripts/config -e ZERO_CALL_USED_REGS -m DRM

kmake $kmake_args olddefconfig; or exit
if test "$localmodconfig" = true
    kmake $kmake_args LSMOD=/tmp/modprobed.db localmodconfig; or exit
end
if test "$menuconfig" = true
    kmake $kmake_args menuconfig; or exit
end

make -s kernelrelease >version

kmake $kmake_args all; or exit

set kernver (cat version)
set modulesdir $pkgdir/usr/lib/modules/$kernver

install -Dm644 (make -s image_name) $modulesdir/vmlinuz; or exit
echo "$pkg" | install -Dm644 /dev/stdin $modulesdir/pkgbase; or exit
cbl_upd_krnl_pkgver $pkg
kmake $kmake_args INSTALL_MOD_PATH=$pkgdir/usr INSTALL_MOD_STRIP=1 modules_install; or exit
rm $modulesdir/{source,build}

pushd $pkgroot
command makepkg -R; or exit
popd

printf '\a'
