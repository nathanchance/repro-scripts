#!/usr/bin/env fish

if not test -f $HOME/.muttrc.notifier
    print_error "This script requires .muttrc.notifier!"
    return 1
end

set root $TMP_FOLDER/pgo-slim-benchmarking
mkdir -p $root

# Folders
set build $root/build
set install $root/install
set llvm $root/llvm-project
set lnx $root/linux
set tc_bld $root/tc-build

# Clone repos
test -d $tc_bld; or git clone -b pgo-slim https://github.com/nathanchance/tc-build $tc_bld
git -C $tc_bld remote update origin; or return
git -C $tc_bld reset --hard origin/pgo-slim; or return

test -d $llvm; or git clone https://github.com/llvm/llvm-project $llvm
git -C $llvm reset --hard 85f6b15ee50feb316047f52d4bd6ddc639e3c5c1; or return

test -d $lnx; or git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/ $lnx
git -C $lnx reset --hard v5.18-rc6; or return

set llvm_instal_normal $install/normal
set llvm_install_pgo $install/pgo
set llvm_install_pgo_slim $install/pgo-slim

set bld_llvm_base \
    $tc_bld/build-llvm.py \
    --build-folder $build \
    --llvm-folder $llvm \
    --no-ccache \
    --projects '"clang;lld"' \
    --targets '"AArch64;ARM;X86"'

set hyperfine_args \
    --command-name "Normal two-stage build" \
    --command-name "PGO (multiple kernel builds)" \
    --command-name "PGO (one kernel build)" \
    --shell fish \
    --runs 1 \
    --warmup 1

hyperfine \
    --export-markdown $root/llvm-results.md \
    $hyperfine_args \
    --prepare "rm -fr $build $llvm_install_normal" \
    --prepare "rm -fr $build $llvm_install_pgo" \
    --prepare "rm -fr $build $llvm_install_pgo_slim" \
    "$bld_llvm_base --install-folder $llvm_install_normal" \
    "$bld_llvm_base --install-folder $llvm_install_pgo --pgo kernel-defconfig" \
    "$bld_llvm_base --install-folder $llvm_install_pgo_slim --pgo kernel-defconfig-slim"; or return

# arm defconfig
hyperfine \
    --export-markdown $root/arm-defconfig-results.md \
    $hyperfine_args \
    --prepare "git -C $lnx cl -q" \
    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_normal/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_pgo/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_pgo_slim/bin/ defconfig all"; or return

# arm64 defconfig
hyperfine \
    --export-markdown $root/arm64-defconfig-results.md \
    $hyperfine_args \
    --prepare "git -C $lnx cl -q" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_normal/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_pgo/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_pgo_slim/bin/ defconfig all"; or return

# x86_64 defconfig
hyperfine \
    --export-markdown $root/x86_64-defconfig-results.md \
    $hyperfine_args \
    --prepare "git -C $lnx cl -q" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_normal/bin/ defconfig all" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_pgo/bin/ defconfig all" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_pgo_slim/bin/ defconfig all"; or return

echo CONFIG_WERROR=n >$root/werror.config

# arm allmodconfig
hyperfine \
    --export-markdown $root/arm-allmodconfig-results.md \
    $hyperfine_args \
    --prepare "git -C $lnx cl -q" \
    "kmake -C $lnx ARCH=arm CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_normal/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_pgo/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_pgo_slim/bin/ allmodconfig all"; or return

# arm64 allmodconfig
hyperfine \
    --export-markdown $root/arm64-allmodconfig-results.md \
    $hyperfine_args \
    --prepare "git -C $lnx cl -q" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_normal/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_pgo/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_pgo_slim/bin/ allmodconfig all"; or return

# x86_64 allmodconfig
hyperfine \
    --export-markdown $root/x86_64-allmodconfig-results.md \
    $hyperfine_args \
    --prepare "git -C $lnx cl -q" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_normal/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_pgo/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 KCONFIG_ALLCONFIG=$root/werror.config LLVM=$llvm_install_pgo_slim/bin/ allmodconfig all"; or return

for results in $root/*.md
    mail_msg $results
end
