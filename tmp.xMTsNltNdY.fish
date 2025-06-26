#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing
set cfg $bld/.config

remkdir $bld

crl -o $cfg https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-aarch64-fedora.config
or return 128

if string match -qr UBSAN_INTEGER_WRAP <lib/Kconfig.ubsan
    sed -i 's;CONFIG_UBSAN_SIGNED_WRAP;CONFIG_UBSAN_INTEGER_WRAP;g' $cfg
end
scripts/config \
    --file $cfg \
    -d DEBUG_INFO \
    -d DEBUG_INFO_DWARF4 \
    -d DEBUG_INFO_DWARF5 \
    -d DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT \
    -d LTO_NONE \
    -e CFI_CLANG \
    -e DEBUG_INFO_NONE \
    -e IKCONFIG \
    -e IKCONFIG_PROC \
    -e LOCALVERSION_AUTO \
    -e LTO_CLANG_THIN \
    -e SHADOW_CALL_STACK \
    --set-val FRAME_WARN 1500 \
    --set-val NR_CPUS 256

if test -f lib/tests/fortify_kunit.c
    set target lib/tests/fortify_kunit.o
else
    set target lib/fortify_kunit.o
end
kmake ARCH=arm64 (korg_llvm var) O=$bld olddefconfig $target
