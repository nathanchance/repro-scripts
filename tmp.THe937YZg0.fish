#!/usr/bin/env fish

set lnx $CBL_SRC/linux-next

if false
    git cp -n 6692c98c7df53502adb8b8b73ab9bcbd399f7a06
    git cp -n dd621ee0cf8eb32445c8f5f26d3b7555953071d8
end

podcmd nathan/gcc-10 kmake -C $lnx ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- distclean multi_v5_defconfig all
set make_ret $status
git rh
if test $make_ret -ne 0
    exit 125
end

podcmd kboot -a arm32_v5 -k $lnx -t 45s

set qemu_ret $status

if test $qemu_ret -eq 0
    exit 0
else if test $qemu_ret -eq 124
    exit 1
else
    exit 125
end
