#!/usr/bin/env fish

set kmake_args \
    -C $CBL_WRKTR/linux-next-bisect \
    ARCH=x86_64 \
    LLVM=1 \
    O=build/x86_64

set kmake_targets \
    mrproper \
    allmodconfig \
    drivers/gpu/drm/amd/amdgpu/

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(echo CONFIG_FRAME_WARN=0 | psub) \
    $kmake_targets; or return 125

kmake \
    $kmake_args \
    $kmake_targets
