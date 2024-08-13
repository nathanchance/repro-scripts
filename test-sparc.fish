#!/usr/bin/env fish

set llvm_src $CBL_SRC_W/llvm-project/sparc
set llvm_bld (tbf $llvm_src)

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder $llvm_src \
    --projects clang lld \
    --quiet-cmake \
    --targets Sparc (get_host_llvm_target)
or return

set lnx_src $CBL_SRC_W/linux/sparc
set lnx_bld (tbf $lnx_src)

if not command -q sparc64-linux-gnu-elfedit
    switch (get_distro)
        case arch
            sudo pacman -U --noconfirm $GITHUB_FOLDER/arch-repo/x86_64/sparc64-linux-gnu-binutils-*-x86_64.pkg.tar.zst
        case fedora
            sudo dnf install -y binutils-sparc64-linux-gnu
        case '*'
            print_error "Don't know how to install sparc64 binutils for this distro?"
            exit 1
    end
    or exit
end

kmake \
    -C $lnx_src \
    ARCH=sparc \
    CC=$llvm_bld/final/bin/clang \
    CROSS_COMPILE=sparc64-linux-gnu- \
    LLVM_IAS=0 \
    O=$lnx_bld \
    mrproper defconfig all
or exit

set initrd /tmp/sparc64-rootfs.cpio
if not test -e $initrd
    crl https://github.com/groeck/linux-build-test/raw/master/rootfs/sparc64/rootfs.cpio.gz | gzip -d >$initrd
    or exit
end

if not command -q qemu-system-sparc64
    switch (get_distro)
        case fedora
            sudo dnf install -y qemu-system-sparc64
        case '*'
            print_error "Don't know how to install sparc64 binutils for this distro?"
            exit 1
    end
    or exit
end

qemu-system-sparc64 \
    -M sun4u \
    -append console=ttyS0 \
    -cpu 'TI UltraSparc IIi' \
    -display none \
    -initrd $initrd \
    -kernel $lnx_bld/arch/sparc/boot/image \
    -m 512 \
    -no-reboot \
    -serial mon:stdio
