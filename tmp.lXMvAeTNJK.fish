#!/usr/bin/env fish

# Set up
sed -i 's/KERNELRELEASE =.*/KERNELRELEASE = 5.15.0/g' Makefile
git cl -q
crl -o .config https://github.com/archlinux/svntogit-packages/raw/packages/linux/trunk/config

PO=$CBL_SRC/llvm-project/build/stage1/bin kmake LLVM=1 olddefconfig drivers/nvme/
set ret $status

# Clean up
git rh

set fish_trace 1
exit $ret
