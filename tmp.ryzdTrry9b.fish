#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects clang \
    --targets SystemZ; or return 125

kmake \
    -C $CBL_SRC/linux \
    ARCH=s390 \
    CC=$llvm_bld/stage1/bin/clang \
    CROSS_COMPILE=s390x-linux-gnu- \
    LLVM_IAS=0 \
    KCONFIG_ALLCONFIG=(printf "%s\n%s\n" CONFIG_RANDSTRUCT_NONE=y CONFIG_WERROR=n | psub) \
    O=$TMP_BUILD_FOLDER/linux-bisect \
    mrproper allmodconfig drivers/infiniband/core/cma.o &| grep "error: call to __read_overflow declared with 'error' attribute:"
switch "$pipestatus"
    case "2 0"
        return 0 # Reverse bisect
    case "0 1"
        return 1 # Reverse bisect
    case '*'
        return 125
end
