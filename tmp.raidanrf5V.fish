#!/usr/bin/env fish

if not test -e llvm/CMakeLists.txt
    print_error "Not in an LLVM tree?"
    return 1
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
    --targets Hexagon (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

$PYTHON_SCRIPTS_FOLDER/kmake.py \
    -C $lnx_src \
    ARCH=hexagon \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig lib/fortify_kunit.o
