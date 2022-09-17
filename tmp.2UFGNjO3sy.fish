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
    --targets "ARM;X86"; or return 125

set lnx_src $CBL_SRC/linux-next
set lnx_bld $TMP_BUILD_FOLDER/(basename $lnx_src)-bisect

set kmake_args \
    -C $lnx_src \
    ARCH=arm \
    CCACHE=0 \
    CROSS_COMPILE=arm-linux-gnu- \
    LLVM=$llvm_bld/stage1/bin/ \
    LLVM_IAS=0 \
    O=$lnx_bld

rm -fr $lnx_bld
kmake $kmake_args allnoconfig; or return 125
$lnx_src/scripts/config \
    --file $lnx_bld/.config \
    -e KUNIT \
    -e RUNTIME_TESTING_MENU \
    -e OVERFLOW_KUNIT_TEST
kmake $kmake_args olddefconfig all &| grep "ld.lld: error: undefined symbol: __mulodi4"
switch "$pipestatus"
    case "0 1"
        echo "Build successful but returning fail for git bisect"
        return 1 # reverse bisect
    case "* 0"
        echo "Build failed but returning success for git bisect"
        return 0
    case "*"
        echo "Build failed for another reason, skipping revision"
        return 125
end
