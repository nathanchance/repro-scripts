#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build
set llvm_src $CBL_WRKTR/llvm-project-bisect
set bld_root (mktemp -d -p $TMP_BUILD_FOLDER)
set llvm_bld $bld_root/llvm

if not test -x $tc_bld/install/bin/powerpc-linux-gnu-as
    $tc_bld/build-binutils.py -t powerpc; or return 125
end

if not $tc_bld/build-llvm.py \
        --assertions \
        --build-folder $llvm_bld \
        --build-stage1-only \
        --llvm-folder $llvm_src \
        --projects 'clang;lld' \
        --targets 'PowerPC;X86'
    rm -fr $bld_root
    return 125
end

set lnx_src $CBL_WRKTR/linux-bisect
set lnx_bld $bld_root/linux

if not make \
        -C $lnx_src \
        -skj(nproc) \
        ARCH=powerpc \
        CROSS_COMPILE=$tc_bld/install/bin/powerpc-linux-gnu- \
        LLVM=1 \
        LLVM_IAS=0 \
        O=$lnx_bld \
        mrproper pmac32_defconfig vmlinux
    rm -fr $bld_root
    return 125
end

$CBL_GIT/boot-utils/boot-qemu.py \
    -a ppc32_mac \
    -k $lnx_bld \
    -t 1m
