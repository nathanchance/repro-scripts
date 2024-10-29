#!/usr/bin/env fish

in_kernel_tree
or return 128

function perform_test
    set lnx_bld (tbf)-bisect

    set kmake \
        $PYTHON_SCRIPTS_FOLDER/kmake.py \
        ARCH=x86_64 \
        (korg_llvm var) \
        O=$lnx_bld

    $kmake mrproper defconfig
    or exit 125

    if contains -- --lto $argv
        scripts/config \
            --file $lnx_bld/.config \
            -d LTO_NONE \
            -e LTO_CLANG_THIN

        $kmake olddefconfig
        or exit 125
    end

    $kmake bzImage
    or exit 125

    U=0 kboot -k $lnx_bld -t 30s
end

perform_test
or exit 125

perform_test --lto
switch $status
    case 0
        exit 0
    case 124
        exit 1
end
exit 125
