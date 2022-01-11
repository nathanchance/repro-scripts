#!/usr/bin/env fish

set host_arch (uname -m)

# Test the tree first to make sure all configurations pass, otherwise benchmark will fail
for tree in linux{,-fast-header}
    for target_arch in arm64 x86_64
        for config in {def,all{mod,yes}}config
            for compiler in gcc clang
                set -l make_args

                if test $compiler = clang
                    set make_args LLVM=1
                else
                    switch "$host_arch:$target_arch"
                        case aarch64:x86_64
                            set make_args CROSS_COMPILE=x86_64-linux-gnu-
                        case x86_64:aarch64
                            set make_args CROSS_COMPILE=aarch64-linux-gnu-
                    end
                end

                kmake -C $CBL_SRC/$tree ARCH=$target_arch HOSTCFLAGS=-Wno-deprecated-declarations $make_args $config all; or exit
            end
        end
    end
end

# Print information about machine, source code version, and compiler versions
echo "Machine information"
echo "==================="
echo "Architecture: $host_arch"
echo "Kernel: "(uname -r)
echo "Logical CPUs: "(grep -c "^processor" /proc/cpuinfo)" @ "(math (cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq) / 1000000)"GHz"
echo "Memory: "(math round (grep MemTotal /proc/meminfo | awk '{print $2}') / 1024000)"GB"
echo

echo "Source information"
echo "=================="
echo "linux HEAD: "(git -C $CBL_SRC/linux kf)
echo "linux-fast-headers HEAD: "(git -C $CBL_SRC/linux-fast-headers kf)
echo

echo "Compiler information"
echo "===================="
echo (command -v clang)": "(clang --version | head -1)
echo (command -v gcc)": "(gcc --version | head -1)
echo

# Actually do the benchmark
for target_arch in arm64 x86_64
    for config in {def,all{mod,yes}}config
        for compiler in gcc clang
            set -l make_args

            if test $compiler = clang
                set make_args LLVM=1
            else
                switch "$host_arch:$target_arch"
                    case aarch64:x86_64
                        set make_args CROSS_COMPILE=x86_64-linux-gnu-
                    case x86_64:aarch64
                        set make_args CROSS_COMPILE=aarch64-linux-gnu-
                end
            end

            hyperfine \
                --command-name "ARCH=$target_arch CC=$compiler $config ({tree})" \
                --parameter-list tree linux,linux-fast-headers \
                --prepare "git -C $CBL_SRC/{tree} cl -q" \
                --runs 10 \
                --shell /bin/fish \
                --warmup 1 \
                "kmake -C $CBL_SRC/{tree} ARCH=$target_arch $make_args $config all"
            echo

        end
    end
end
