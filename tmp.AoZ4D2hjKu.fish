#!/usr/bin/env fish

switch (uname -m)
    case aarch64
        set arches \
            arm32_v7 \
            arm64{,be} \
            x86{,_64}
    case x86_64
        set arches \
            arm32_v{5,6,7} \
            arm64{,be} \
            m68k \
            mips{,el} \
            ppc{32{,_mac},64{,le}} \
            riscv \
            s390 \
            x86{,_64}
end

for arch in $arches
    set cmd \
        $CBL_GIT/boot-utils/boot-qemu.py \
        -a $arch \
        -k $TMP_BUILD_FOLDER/linux-qemu-testing/$arch
    echo "\$ $cmd"
    $cmd; or return
end
