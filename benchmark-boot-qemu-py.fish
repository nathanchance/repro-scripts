#!/usr/bin/env fish

set arches \
    arm32_v7 \
    arm64{,be} \
    x86{,_64}

set boot_qemu_sh $CBL_GIT/boot-utils-ro/boot-qemu.sh
if not test -x $boot_qemu_sh
    git clone https://github.com/ClangBuiltLinux/boot-utils (dirname $boot_qemu_sh)
end
git -C (dirname $boot_qemu_sh) urh

set boot_utils $CBL_GIT/boot-utils
set boot_qemu_py $boot_utils/boot-qemu.py
if not test -x $boot_qemu_py
    cbl_clone_repo boot-utils
    git -C $boot_utils urh
    git pull --no-{edit,ff} https://github.com/nathanchance/boot-utils python-rewrite
end

for arch in $arches
    set -l args \
        -a $arch \
        -k $TMP_BUILD_FOLDER/linux-qemu-testing/$arch

    echo
    echo "$arch:"
    echo

    hyperfine \
        --command-name (basename $boot_qemu_sh) \
        --command-name (basename $boot_qemu_py) \
        --warmup 1 \
        "$boot_qemu_sh $args" \
        "$boot_qemu_py $args"
end
