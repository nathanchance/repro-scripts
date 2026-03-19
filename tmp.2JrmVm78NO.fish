#!/usr/bin/env fish

function build_kernel
    kmake \
        ARCH=arm \
        KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
        $argv \
        O=(tbf)-testing \
        mrproper allmodconfig drivers/gpu/drm/xe/xe_ring_ops.o
end

build_kernel (korg_llvm var 18)
or return 125

build_kernel (korg_llvm var 20)
or return 125

build_kernel (korg_llvm var 19)
