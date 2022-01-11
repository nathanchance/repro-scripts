#!/usr/bin/env fish

set lnx $CBL_SRC/linux-stable-4.14

# Build kernel
podcmd $GHCR/gcc-7 kmake -C $lnx ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- distclean defconfig; or exit 125
$lnx/scripts/config --file $lnx/.config -e CPU_BIG_ENDIAN; or exit 125
podcmd $GHCR/gcc-7 kmake -C $lnx ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig Image.gz; or exit 125

# Boot kernel
podcmd kboot -a arm64be -k $lnx -t 25s
exit

set exit $status

# Reverse bisect so good is bad and bad is good
if test $exit -eq 0
    exit 1
else if test $exit -eq 124
    exit 0
else
    exit 125
end
