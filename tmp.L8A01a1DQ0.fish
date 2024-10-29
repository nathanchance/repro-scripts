#!/usr/bin/env fish

if not test -e llvm/CMakeLists.txt
    print_error "Not in an LLVM tree?"
    return 128
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
    --show-build-commands \
    --targets PowerPC (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-bisect

kmake \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc64-linux-gnu- \
    LLVM=$llvm_bld/final/bin/ \
    LLVM_IAS=0 \
    O=$lnx_bld \
    mrproper pmac32_defconfig all &| grep 'fatal error: error in backend: Trying to obtain a reserved register "r2"'
switch "$pipestatus"
    case "0 1"
        return 0
    case "1 0"
        return 1
end
return 125
