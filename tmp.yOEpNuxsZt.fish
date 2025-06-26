#!/usr/bin/env fish

in_tree kernel
or return 128

set crypto_cfg arch/riscv/configs/crypto.config
if not test -e $crypto_cfg
    printf 'CONFIG_CRYPTO_%s_RISCV64=y\n' SHA{256,512} SM3 >$crypto_cfg
end

set cfi_cfg kernel/configs/cfi.config
if not test -e $cfi_cfg
    echo CONFIG_CFI_CLANG=y >$cfi_cfg
end

set kmake \
    kmake \
    ARCH=riscv \
    (korg_llvm var) \
    O=(tbf)-testing

if string match -eq __vdso_getrandom <arch/riscv/kernel/vdso/vdso.lds.S
    b4 -q am -o - 20250423-riscv-fix-compat_vdso-lld-v2-1-b7bbbc244501@kernel.org | git ap
    or return 128
end

begin
    $kmake mrproper {def,crypto.}config vmlinux
    and $kmake mrproper {def,cfi.}config vmlinux
end
or set ret 125

if not set -q ret
    $kmake mrproper {def,crypto.,cfi.}config vmlinux
    set ret $status
end

git rh
return $ret
