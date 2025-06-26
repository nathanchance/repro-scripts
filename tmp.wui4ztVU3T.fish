#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

set kmake \
    kmake \
    ARCH=arm64 \
    (korg_llvm var) \
    O=$bld

if test -f lib/tests/fortify_kunit.c
    set target lib/tests/fortify_kunit.o
else
    set target lib/fortify_kunit.o
end

$kmake {virt,fortify-kunit.}config $target
or return

$kmake {virt,fortify-kunit.,ubsan-bounds.}config $target
