#!/usr/bin/env fish

# Variables
set host_arch (uname -m)

set lnx_git $CBL_SRC/linux
set lnx_src $CBL_WRKTR/linux-benchmark
set lnx_bld $TMP_BUILD_FOLDER/linux
set lnx_version v6.1-rc3

set llvm_git $CBL_SRC/llvm-project
set llvm_src $CBL_WRKTR/llvm-project-benchmark
set llvm_bld $TMP_BUILD_FOLDER/llvm
set llvm_install $TMP_FOLDER/install/llvm
set llvm_version llvmorg-15.0.4

set tc_bld $CBL_GIT/tc-build

set base_bld_llvm_cmd \
    $tc_bld/build-llvm.py \
    --build-folder $llvm_bld \
    --check-targets clang ll{d,vm{,-unit}} \
    --install-folder $llvm_install \
    --llvm-folder $llvm_src \
    --no-ccache \
    --projects '"clang;lld"'

set base_hyperfine_cmd \
    hyperfine \
    --runs 3 \
    --warmup 1

set base_make_cmd \
    make \
    -C $lnx_src \
    -skj(nproc) \
    O=$lnx_bld

# Initial checks
in_container_msg -c; or return
command -q hyperfine; or upd hyperfine
cbl_clone_repo linux llvm-project tc-build

# Update sources
git -C $llvm_git ru; or return
git -C $lnx_git ru; or return
git -C $tc_bld urh; or return

# Create worktrees
rm -fr $llvm_src $lnx_src

git -C $llvm_git worktree prune
git -C $lnx_git worktree prune

git -C $llvm_git worktree add \
    --detach \
    $llvm_src \
    $llvm_version

git -C $lnx_git worktree add \
    --detach \
    $lnx_src \
    $lnx_version

# Print toolchain information
set binaries \
    clang \
    ld.lld \
    gcc \
    ld
switch $host_arch
    case aarch64
        set -a binaries \
            x86_64-linux-gnu-{gcc,ld}
    case x86_64
        set -a binaries \
            aarch64-linux-gnu-{gcc,ld}
end

header "Toolchain information"
for binary in $binaries
    $binary --version | head -n1
end

# Test arm64 and x86_64 defconfig and allmodconfig with both GCC and LLVM
header "defconfig + allmodconfig"
for config in defconfig allmodconfig
    for arch in arm64 x86_64
        for toolchain in GCC LLVM
            set -l make_args \
                ARCH=$arch
            switch $toolchain
                case GCC
                    switch "$arch:$host_arch"
                        case "arm64:x86_64"
                            set -a make_args \
                                CROSS_COMPILE=aarch64-linux-gnu-
                        case "x86_64:aarch64"
                            set -a make_args \
                                CROSS_COMPILE=x86_64-linux-gnu-
                    end
                case LLVM
                    set -a make_args \
                        LLVM=1
            end

            $base_hyperfine_cmd \
                --command-name "$arch $config ($toolchain)" \
                --prepare "rm -fr $lnx_bld" \
                "$base_make_cmd $make_args $config all"; or return
        end
    end
end

# Test arm64 and x86_64 ThinLTO defconfig and allmodconfig
header "defconfig + allmodconfig (ThinLTO)"
for config in defconfig allmodconfig
    for arch in arm64 x86_64
        set -l make_args \
            ARCH=$arch \
            LLVM=1

        set -l prepare_cmd
        switch $config
            case defconfig
                set prepare_cmd \
                    "rm -fr $lnx_bld &&
$base_make_cmd $make_args $config &&
$lnx_src/scripts/config --file $lnx_bld/.config -d LTO_NONE -e LTO_CLANG_THIN &&
$base_make_cmd $make_args olddefconfig &&
{ grep -q ^CONFIG_LTO_CLANG_THIN=y $lnx_bld/.config || exit 1; }"
            case allmodconfig
                mkdir -p $TMP_FOLDER
                set tmp_file (mktemp -p $TMP_FOLDER)
                set prepare_cmd \
                    "rm -fr $lnx_bld &&
printf 'CONFIG_GCOV_KERNEL=n\nCONFIG_KASAN=n\nCONFIG_LTO_CLANG_THIN=y\n' >$tmp_file &&
$base_make_cmd $make_args KCONFIG_ALLCONFIG=$tmpfile allmodconfig &&
rm -fr $tmp_file &&
{ grep -q ^CONFIG_LTO_CLANG_THIN=y $lnx_bld/.config || exit 1; }"
        end

        $base_hyperfine_cmd \
            --command-name "$arch $config + ThinLTO" \
            --prepare "$prepare_cmd" \
            "$base_make_cmd $make_args all"; or return
    end
end

# Test building LLVM with and without PGO
header LLVM
for build_type in two-stage pgo-defconfig pgo-defconfig-allmodconfig
    set -l bld_llvm_args
    switch $build_type
        case pgo-defconfig
            set -a bld_llvm_args \
                --pgo kernel-defconfig
        case pgo-defconfig-allmodconfig
            set -a bld_llvm_args \
                --pgo kernel-{def,allmod}config
    end

    $base_hyperfind_cmd \
        --command-name "$(basename $base_bld_llvm_cmd[1]) ($build_type)" \
        --prepare "rm -fr $llvm_bld $llvm_install" \
        "$base_bld_llvm_cmd $bld_llvm_args"; or return
end

rm -fr $llvm_src $lnx_src
git -C $llvm_git worktree prune
git -C $lnx_git worktree prune
