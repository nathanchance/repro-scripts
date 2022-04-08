#!/usr/bin/env fish

set qemu_src $CBL_WRKTR/qemu-bisect-arm64-boot-failure-4.14
set qemu_bld $qemu_src/build

git -C $qemu_src cl -q
git -C $qemu_src submodule update --init --recursive

mkdir -p $qemu_bld
cd $qemu_bld; or return 125

# Build QEMU
$qemu_src/configure \
    --disable-docs \
    --target-list=aarch64-softmmu; or return 125
make -skj(nproc); or return 125

set qemu_arm64 $qemu_bld/qemu-system-aarch64
set qemu_args \
    -initrd $CBL_GIT/boot-utils-ro/images/arm64/rootfs.cpio \
    -append 'console=ttyAMA0 earlycon' \
    -machine virt-6.2,gic-version=max \
    -machine virtualization=true \
    -display none \
    -m 512m \
    -nodefaults \
    -serial mon:stdio

#if rg -q arm_cpu_lpa2_finalize $qemu_src/target/arm/cpu.h
#    set lpa2 ,lpa2=off
#end

set kimg_414 $CBL_SRC/linux-stable-4.14/arch/arm64/boot/Image.gz
set kimg_419 $CBL_SRC/linux-stable-4.19/arch/arm64/boot/Image.gz

set fish_trace 1

# 4.19 should be fine, otherwise revision is chalked
timeout --foreground 45s $qemu_arm64 -kernel $kimg_419 $qemu_args -cpu "max$lpa2"; or return 125

# 4.14 with '-cpu cortex-a72' should work
timeout --foreground 45s $qemu_arm64 -kernel $kimg_414 $qemu_args -cpu cortex-a72; or return 125

# 4.14 with '-cpu max' has issues
timeout --foreground 45s $qemu_arm64 -kernel $kimg_414 $qemu_args -cpu "max$lpa2"
