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
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-bisect

prep_config https://download.01.org/0day-ci/archive/20240813/202408131601.Aj9JmK7K-lkp@intel.com/config $lnx_bld

kmake \
    -C $lnx_src \
    ARCH=um \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig lib/test_bitmap.o &| grep -P "error: call to '__compiletime_assert_[0-9]+' declared with 'error' attribute: BUILD_BUG_ON failed: !__builtin_constant_p\(~var\)"
switch "$pipestatus"
    case "0 1"
        return 0
    case "1 0"
        return 1
    case "*"
        return 125
end
