#!/usr/bin/env fish

set arches \
    arm32_v7 \
    arm64{,be} \
    x86{,_64}

for arch in $arches
    echo
    echo "$arch:"
    echo
    hyperfine \
        --command-name "boot-qemu.sh" \
        --command-name "boot-qemu.py" \
        --warmup 1 \
        "$CBL_GIT/boot-utils-ro/boot-qemu.sh -a $arch -k $TMP_BUILD_FOLDER/linux-qemu-testing/$arch" \
        "$CBL_GIT/boot-utils/boot-qemu.py -a $arch -k $TMP_BUILD_FOLDER/linux-qemu-testing/$arch"
end
