#!/usr/bin/env fish

set bntls_bld (tbf)-testing
remkdir $bntls_bld

$CBL_GIT/tc-build/build-binutils.py \
    -B . \
    -b $bntls_bld \
    -i $bntls_bld/install \
    --show-build-commands \
    -t x86_64

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing
set lnx_usr $lnx_bld/usr

set btrfs_ko fs/btrfs/btrfs.ko
set built_btrfs_ko $lnx_bld/$btrfs_ko

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=arm64 \
    (korg_gcc var arm64) \
    INSTALL_MOD_PATH=$lnx_usr \
    O=$lnx_bld

if not test -e $built_btrfs_ko
    $kmake mrproper defconfig all
end

set built_machine (llvm-readelf --file-headers $built_btrfs_ko &| string match -gr '^\s+Machine:\s+(.*)$')
test $built_machine = AArch64
or return 128

remkdir $lnx_usr
$kmake modules_install

set installed_btrfs_ko $lnx_usr/lib/modules/*/kernel/$btrfs_ko
$bntls_bld/install/bin/strip -g $installed_btrfs_ko

set installed_machine (llvm-readelf --file-headers $installed_btrfs_ko &| string match -gr '^\s+Machine:\s+(.*)$')
echo "Machine of $installed_btrfs_ko: $installed_machine"
test $installed_machine != None
