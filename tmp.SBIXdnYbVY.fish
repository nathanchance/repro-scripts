#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

begin
    rm -fr $lnx_bld
    and mkdir -p $lnx_bld
    and cp $CBL_LKT/configs/debian/arm64.config $lnx_bld/.config
    and kmake \
        -C $lnx_src \
        ARCH=arm64 \
        CROSS_COMPILE=/usr/bin/aarch64-linux-gnu- \
        O=$lnx_bld \
        olddefconfig Image.gz
end; or return 125

$CBL_GIT/boot-utils/boot-qemu.py \
    -a arm64 \
    -k $lnx_bld \
    -t 45s
if test $status -eq 0
    return 0
else
    return 1
end
