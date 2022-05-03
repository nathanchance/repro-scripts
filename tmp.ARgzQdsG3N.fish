#!/usr/bin/env fish

set configs \
    powernv_defconfig \
    https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-ppc64le-fedora.config \
    https://github.com/openSUSE/kernel-source/raw/master/config/ppc64le/default

for config in $configs
    set -l build $TMP_BUILD_FOLDER/tuxmake/build
    set -l dist $TMP_BUILD_FOLDER/tuxmake/dist

    rm -fr $build $dist

    set fish_trace 1
    tuxmake \
       -a powerpc \
       -b $build \
       -C $CBL_SRC/linux-next \
       -I zImage.epapr \
       -k $config \
       -o $TMP_BUILD_FOLDER/tuxmake/dist \
       -r podman \
       -t clang-14 \
       LLVM=1 \
       kernel
    set -e fish_trace

    if test $status -eq 0
        dbxe -- $CBL_GIT/boot-utils/boot-qemu.sh -a ppc64le -k $dist/zImage.epapr -t 45s
    end
end
