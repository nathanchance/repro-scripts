#!/usr/bin/env fish

set lnx $CBL_SRC/linux

# Kernel must be buildable, otherwise it is untestable
dbxe gcc-6 -- "fish -c 'kmake -C $lnx ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- distclean defconfig Image.gz'"; or return 125

set qemu_6_cmd timeout --foreground 45s /usr/bin/qemu-system-aarch64
set qemu_7_cmd timeout --foreground 45s $CBL_QEMU_BIN/qemu-system-aarch64
set qemu_args \
    -initrd $CBL_GIT/boot-utils/images/arm64/rootfs.cpio \
    -append "'console=ttyAMA0 earlycon'" \
    -machine virt,gic-version=max \
    -machine virtualization=true \
    -display none \
    -kernel $lnx/arch/arm64/boot/Image.gz \
    -m 512m \
    -nodefaults \
    -serial mon:stdio

# Boot should be okay with old QEMU
dbxe -- $qemu_6_cmd -cpu cortex-a72 $qemu_args; or return 125
dbxe -- $qemu_6_cmd -cpu max $qemu_args; or return 125

# Boot must be okay with '-cpu cortex-a72', otherwise the revision is untestable
dbxe -- $qemu_7_cmd -cpu cortex-a72 $qemu_args; or return 125

# Test '-cpu max,lpa2=off'
dbxe -- $qemu_7_cmd -cpu max,lpa2=off $qemu_args
# Reverse bisect
switch $status
    case 124
        echo "Boot failed as expected, returning '0' for git bisect"
        exit 0
    case 0
        echo "Boot succeeded as expected, returning '1' for git bisect"
        exit 1
    case '*'
        echo "Unexpected error code, returning '125' for git bisect"
        exit 125
end
