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
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

prep_config $CBL_LKT/configs/debian/i386.config $lnx_bld

timeout 25s $PYTHON_SCRIPTS_FOLDER/kmake.py \
    -C $lnx_src \
    ARCH=i386 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig drivers/net/wireless/intel/iwlegacy/4965-mac.o
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
