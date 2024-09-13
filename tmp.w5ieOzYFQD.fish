#!/usr/bin/env fish

if not test -e llvm/CMakeLists.txt
    print_error "Not in an LLVM tree?"
    return 1
end

set llvm_bld (tbf)-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder . \
    --projects clang lld \
    --quiet-cmake \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux-stable-5.10
set lnx_bld (tbf $lnx_src)-bisect

kmake \
    -C $lnx_src \
    -p $llvm_bld/final/bin \
    ARCH=arm64 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    LLVM{,_IAS}=1 \
    O=$lnx_bld \
    mrproper defconfig vmlinux &| grep -P 'relocation R_AARCH64_[A-Z0-9_]+ out of range'
switch "$pipestatus"
    case "0 1"
        return 0
    case "1 0"
        return 1
    case "*"
        return 125
end
