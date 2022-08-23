#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets "PowerPC;X86"; or return 125

set lnx_src $CBL_SRC/linux-stable-5.19
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect
set kmake_args \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc-linux-gnu- \
    LLVM=$llvm_bld/stage1/bin/ \
    LLVM_IAS=0 \
    O=$lnx_bld

begin
    rm -fr $lnx_bld
    and kmake $kmake_args pmac32_defconfig
    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -e PPC_DISABLE_WERROR \
        -e SERIAL_PMACZILOG \
        -e SERIAL_PMACZILOG_CONSOLE
    and kmake $kmake_args olddefconfig vmlinux
end; or return 125

$CBL_GIT/boot-utils/boot-qemu.py \
    -a ppc32_mac \
    -k $lnx_bld \
    -t 45s
switch $status
    case 0
        return 1 # reverse bisect
    case 124
        return 0 # reverse bisect
    case '*'
        return 125
end
