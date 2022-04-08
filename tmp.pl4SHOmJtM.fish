#!/usr/bin/env fish

in_container_msg -c; or return 125

set lnx $CBL_SRC/linux-next

if not rg -q CLANG_TARGET_FLAGS_um $lnx/scripts/Makefile.clang
    git -C $lnx cp -n c7500c1b53bfc083e8968cdce13a5a9d1ca9bf83
end

# Build kernel
kmake -C $lnx ARCH=um LLVM=1 mrproper defconfig all; or return 125

# Extract rootfs
set root_fs $lnx/root_fs
set root_fs_cpio $root_fs/rootfs.cpio
sudo fish -c "rm -fr $root_fs
and mkdir $root_fs
and zstd -d -o $root_fs_cpio $CBL_GIT/boot-utils/images/x86_64/rootfs.cpio.zst
and cpio -D $root_fs -div <$root_fs_cpio
rm $root_fs_cpio"; or return 125

# Boot kernel
$lnx/linux rootfstype=hostfs rootflags=$root_fs
$lnx/linux rootfstype=hostfs rootflags=$root_fs &| rg "wait_stub_done : failed to wait for SIGTRAP"
switch "$pipestatus"
    case "134 0"
        set ret 1
    case "0 1"
        set ret 0
    case "*"
        set ret 125
end

# Clean up
sudo rm -fr $root_fs
git -C $lnx rh
return $ret
