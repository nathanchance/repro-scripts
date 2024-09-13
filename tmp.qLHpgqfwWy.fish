#!/usr/bin/env fish

in_kernel_tree
or return

set bld (tbf)-bisect

function perform_test
    for arg in $argv
        switch $arg
            case --no-lto
                set skip_lto true
            case '*'
                set -a kmake_args $arg
        end
    end

    set kmake \
        $PYTHON_SCRIPTS_FOLDER/kmake.py \
        ARCH=i386 \
        $kmake_args \
        O=$bld

    begin
        $kmake mrproper defconfig
        if string match -qr LLVM= "$kmake"; and not set -q skip_lto
            scripts/config --file $bld/.config -d LTO_NONE -e LTO_CLANG_THIN
            and $kmake olddefconfig
        end
        and $kmake bzImage
    end
    or return 125

    python3 -c "import subprocess
import sys

cmd = [
    '$CBL_LKT/src/boot-utils/boot-qemu.py',
    '-a', 'x86',
    '-k', '$bld',
    '--gh-json-file', '$CBL_LOGS/linux-next-2024-08-14-22:06:33/.boot-utils.json',
    '-m', '2G',
]

run_kwargs = {
    'capture_output': True,
    'check': True,
    'text': True,
}

try:
    proc = subprocess.run(cmd, **run_kwargs, errors='replace')
except subprocess.CalledProcessError as err:
    print('subprocess.run(cmd, errors=\'replace\') failed?')
    print(err)
    sys.exit(125)

try:
    proc = subprocess.run(cmd, **run_kwargs)
except UnicodeDecodeError as err:
    print(err)
    sys.exit(1)
except subprocess.CalledProcessError as err:
    print(err)
    sys.exit(125)
else:
    print(f'{cmd} ran sucessfully')
    sys.exit(0)"
end

perform_test (korg_gcc var)
or return

perform_test --no-lto (korg_llvm var)
or return

perform_test (korg_llvm var)
