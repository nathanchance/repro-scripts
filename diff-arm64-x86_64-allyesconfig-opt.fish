#!/usr/bin/env fish

if not test (uname -m) = x86_64
    print_error "This script assumes an x86_64 host!"
    exit 1
end

if test -z "$container"
    print_error "This script needs to be run in a container!"
    exit 1
end

cd $CBL_SRC/linux-next; or exit

for arch in arm64 x86_64
    for compiler in clang gcc
        for optimization in 2 s

            # Set the correct make flags
            set -l make_args
            switch "$arch:$compiler"
                case arm64:gcc
                    set make_args CROSS_COMPILE=aarch64-linux-gnu-
                case '*':clang
                    set make_args LLVM=1
            end

            # Set the optimization level via Kconfig
            switch optimization
                case 2
                    echo CONFIG_WERROR=n >allyes.config
                case s
                    echo "CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=n
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_WERROR=n" >allyes.config
            end

            # Build the kernel
            kmake \
                ARCH=$arch \
                $make_args \
                O=.build/$arch-$compiler-O$optimization \
                distclean allyesconfig vmlinux; or exit
        end
    end
end

echo
echo

clang --version | head -1
gcc --version | head -1
aarch64-linux-gnu-gcc --version | head -1
echo

for arch in arm64 x86_64
    for compiler in clang gcc
        set vmlinux_O2 .build/$arch-$compiler-O2/vmlinux
        set vmlinux_Os .build/$arch-$compiler-Os/vmlinux

        echo
        echo "ARCH=$arch CC=$compiler:"
        printf "  -O2: "
        diskus $vmlinux_O2

        printf "  -Os: "
        diskus $vmlinux_Os

        set vmlinux_size_O2 (diskus $vmlinux_O2)
        set vmlinux_size_Os (diskus $vmlinux_Os)

        set diff_mb (math -s2 "($vmlinux_size_Os - $vmlinux_size_O2)" / 10000000)
        set diff_per (math -s2 "($vmlinux_size_Os - $vmlinux_size_O2) * 100" / $vmlinux_size_Os)

        echo "  Difference: $diff_mb MB ($diff_per%)"
    end
end
