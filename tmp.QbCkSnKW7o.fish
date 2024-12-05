#!/usr/bin/env fish

if not test -e llvm/CMakeLists.txt
    print_error "Not in an LLVM tree?"
    return 128
end

set llvm_bld (tbf)-testing

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder . \
    --projects clang lld \
    --quiet-cmake \
    --targets ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper multi_v5_defconfig mm/mm_init.o &| grep "Can't create node that may be undef/poison"
set ret $pipestatus
switch "$ret"
    case "0 1" "1 0"
        return $ret[1]
end
return 125
