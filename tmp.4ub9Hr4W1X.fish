#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

rm -fr $lnx_bld
tuxmake \
    --build-dir $lnx_bld \
    --directory $lnx_src \
    --kconfig https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-ppc64le-fedora.config \
    --kconfig-add CONFIG_BPF_PRELOAD=n \
    --kconfig-add CONFIG_DEBUG_INFO_BTF=n \
    --kernel-image zImage.epapr \
    --output-dir $lnx_bld/dist \
    --target-arch powerpc \
    LLVM=1 \
    default; or return 125

$CBL_GIT/boot-utils/boot-qemu.py \
    -a ppc64le \
    -k $lnx_bld \
    -t 45s
