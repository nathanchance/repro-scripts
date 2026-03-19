#!/usr/bin/env fish

__in_tree kernel
or return 128

if not test -e drivers/net/ethernet/intel/idpf/xsk.c
    echo drivers/net/ethernet/intel/idpf/xsk.c is not present, skipping revision...
    return 125
end

set lnx_bld (tbf)-testing

set kmake \
    kmake \
    ARCH=arm \
    (korg_llvm var) \
    O=$lnx_bld

begin
    $kmake mrproper defconfig

    and scripts/config \
        --file $lnx_bld/.config \
        -e BPF_SYSCALL \
        -e IDPF \
        -e XDP_SOCKETS

    and $kmake olddefconfig drivers/net/ethernet/intel/idpf/xsk.o

    and $kmake mrproper defconfig

    and scripts/config \
        --file $lnx_bld/.config \
        -e BPF_SYSCALL \
        -e CFI \
        -e CFI_CLANG \
        -e IDPF \
        -e XDP_SOCKETS
end
or return 125

$kmake olddefconfig drivers/net/ethernet/intel/idpf/xsk.o &| string match -er "error: call to '__compiletime_assert_\d+' declared with 'error' attribute: BUILD_BUG_ON failed: !__builtin_constant_p\(tmo == libeth_xsktmo\)"
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
