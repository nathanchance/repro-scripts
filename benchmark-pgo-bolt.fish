#!/usr/bin/env fish

if not test -f $HOME/.muttrc.notifier
    print_error "This script requires .muttrc.notifier!"
    return 1
end

set root $TMP_FOLDER/pgo-bolt-benchmarking
mkdir -p $root

# Folders
set build $root/build
set install $root/install
set llvm $root/llvm-project
set lnx $root/linux
set tc_bld $root/tc-build

# Clone repos
test -d $tc_bld; or git clone -b bolt-perf https://github.com/nathanchance/tc-build $tc_bld
git -C $tc_bld remote update origin; or return
git -C $tc_bld reset --hard origin/bolt-perf; or return

test -d $llvm; or git clone https://github.com/llvm/llvm-project $llvm
git -C $llvm reset --hard 794a0bb547484ec33c13bd6c7c04b1dbd03d040a; or return

test -d $lnx; or git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/ $lnx
git -C $lnx reset --hard v5.18-rc3; or return

# set llvm_install_pgo $install/pgo
# set llvm_install_pgo_bolt $install/pgo-bolt
set llvm_install_assertions_pgo $root/assertions-pgo
set llvm_install_assertions_pgo_bolt $root/assertions-pgo-bolt

set bld_llvm_base \
    $tc_bld/build-llvm.py \
    --build-folder $build \
    --llvm-folder $llvm \
    --no-ccache \
    --pgo kernel-defconfig \
    --projects '"clang;lld"' \
    --show-build-commands \
    --targets '"AArch64;ARM;X86"'

set hyperfine_names \
    -n PGO \
    -n "PGO + BOLT" # \
#    -n "PGO (assertions)" \
#    -n "PGO + BOLT (assertions)"

hyperfine \
    --export-markdown $root/llvm-results.md \
    $hyperfine_names \
    #    -p "rm -fr $build $llvm_install_pgo" \
    #    -p "rm -fr $build $llvm_install_pgo_bolt" \
    -p "rm -fr $build $llvm_install_assertions_pgo" \
    -p "rm -fr $build $llvm_install_assertions_pgo_bolt" \
    -S fish \
    -w 1 \
    #    "$bld_llvm_base --install-folder $llvm_install_pgo" \
    #    "$bld_llvm_base --bolt --install-folder $llvm_install_pgo_bolt" \
    "$bld_llvm_base --assertions --install-folder $llvm_install_assertions_pgo" \
    "$bld_llvm_base --assertions --bolt --install-folder $llvm_install_assertions_pgo_bolt"; or return

# arm defconfig
hyperfine \
    --export-markdown $root/arm-defconfig-results.md \
    $hyperfine_names \
    -p "git -C $lnx cl -q" \
    -S fish \
    -w 1 \
    #    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_pgo/bin/ defconfig all" \
    #    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_pgo_bolt/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_assertions_pgo/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm CCACHE=0 LLVM=$llvm_install_assertions_pgo_bolt/bin/ defconfig all"; or return

# arm64 defconfig
hyperfine \
    --export-markdown $root/arm64-defconfig-results.md \
    $hyperfine_names \
    -p "git -C $lnx cl -q" \
    -S fish \
    -w 1 \
    #    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_pgo/bin/ defconfig all" \
    #    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_pgo_bolt/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_assertions_pgo/bin/ defconfig all" \
    "kmake -C $lnx ARCH=arm64 CCACHE=0 LLVM=$llvm_install_assertions_pgo_bolt/bin/ defconfig all"; or return

# x86_64 defconfig
hyperfine \
    --export-markdown $root/x86_64-defconfig-results.md \
    $hyperfine_names \
    -p "git -C $lnx cl -q" \
    -S fish \
    -w 1 \
    #    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_pgo/bin/ defconfig all" \
    #    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_pgo_bolt/bin/ defconfig all" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_assertions_pgo/bin/ defconfig all" \
    "kmake -C $lnx ARCH=x86_64 CCACHE=0 LLVM=$llvm_install_assertions_pgo_bolt/bin/ defconfig all"; or return

echo CONFIG_WERROR=n >$root/werror.config

# arm allmodconfig
hyperfine \
    --export-markdown $root/arm-allmodconfig-results.md \
    $hyperfine_names \
    -p "git -C $lnx cl -q" \
    -S fish \
    -w 1 \
    #    "kmake -C $lnx ARCH=arm KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_pgo/bin/ allmodconfig all" \
    #    "kmake -C $lnx ARCH=arm KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_pgo_bolt/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_assertions_pgo/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_assertions_pgo_bolt/bin/ allmodconfig all"; or return

# arm64 allmodconfig
hyperfine \
    --export-markdown $root/arm64-allmodconfig-results.md \
    $hyperfine_names \
    -p "git -C $lnx cl -q" \
    -S fish \
    -w 1 \
    #    "kmake -C $lnx ARCH=arm64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_pgo/bin/ allmodconfig all" \
    #    "kmake -C $lnx ARCH=arm64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_pgo_bolt/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_assertions_pgo/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=arm64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_assertions_pgo_bolt/bin/ allmodconfig all"; or return

# x86_64 allmodconfig
hyperfine \
    --export-markdown $root/x86_64-allmodconfig-results.md \
    $hyperfine_names \
    -p "git -C $lnx cl -q" \
    -S fish \
    -w 1 \
    #    "kmake -C $lnx ARCH=x86_64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_pgo/bin/ allmodconfig all" \
    #    "kmake -C $lnx ARCH=x86_64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_pgo_bolt/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=x86_64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_assertions_pgo/bin/ allmodconfig all" \
    "kmake -C $lnx ARCH=x86_64 KCONFIG_ALLCONFIG=$root/werror.config CCACHE=0 LLVM=$llvm_install_assertions_pgo_bolt/bin/ allmodconfig all"; or return

for results in $root/*.md
    mail_msg $results
end
