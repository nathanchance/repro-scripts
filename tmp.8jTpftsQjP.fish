#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

set kmake \
    kmake \
    ARCH=riscv \
    O=$bld \
    mrproper defconfig net/socket.o

if git merge-base --is-ancestor 89079520cef65d6da1e864eab4464effe5396e23 HEAD
    b4 am -o - 20250423-riscv-fix-compat_vdso-lld-v2-1-b7bbbc244501@kernel.org | git ap
    or return 128
end

$kmake (korg_llvm var)
or set ret 125

if not set -q ret
    $kmake LLVM=1
    set ret $status
end

git rh
return $ret
