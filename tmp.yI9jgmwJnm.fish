#!/usr/bin/env fish

set kmake_args \
    -C $CBL_SRC/linux \
    ARCH=s390 \
    CC=clang-14 \
    CROSS_COMPILE=s390x-linux-gnu- \
    LLVM_IAS=0 \
    O=$TMP_BUILD_FOLDER/linux-bisect \
    mrproper allmodconfig drivers/infiniband/core/cma.o

kmake $kmake_args KCONFIG_ALLCONFIG=(printf "%s\n%s\n" CONFIG_FORTIFY_SOURCE=n CONFIG_WERROR=n | psub); or return 125
kmake $kmake_args KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub)
