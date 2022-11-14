#!/usr/bin/env fish

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux
set lnx_ver v6.1-rc5

set baseline $CBL_WRKTR/linux-baseline
set patched $CBL_WRKTR/linux-patched

# Ensure source exists
test -d $lnx_src; or cbl_clone_repo linux

# Clean up from a previous run
rm -fr $baseline $patched
git -C $lnx_src worktree prune

# Update source tree
git -C $lnx_src remote update; or return

# Checkout worktrees
git -C $lnx_src worktree add --detach $baseline $lnx_ver; or return
git -C $lnx_src worktree add --detach $patched $lnx_ver; or return

# Apply patch to "patched" worktree
b4 am -l -o - 20221114174617.211980-1-masahiroy@kernel.org | git -C $patched am; or return

# Set up the ThinLTO Kconfig
set kconfig_allconfig (mktemp --suffix=.config)
echo 'CONFIG_GCOV_KERNEL=n
CONFIG_KASAN=n
CONFIG_LTO_CLANG_THIN=y' >$kconfig_allconfig

# Default make command
set kmake \
    make \
    -skj(nproc) \
    ARCH=arm64 \
    LLVM=1

# Test difference
hyperfine \
    --command-name (git -C $baseline kf) \
    --command-name (git -C $patched kf) \
    --parameter-list src $baseline,$patched \
    --prepare "rm -fr $lnx_bld && $kmake -C {src} KCONFIG_ALLCONFIG=$kconfig_allconfig allmodconfig && grep -q CONFIG_LTO_CLANG_THIN=y $lnx_bld/.config" \
    --runs 3 \
    --warmup 1 \
    "$kmake -C {src} all"

# Final cleanup
rm -fr $baseline $kconfig_allconfig $patched
git -C $lnx_src worktree prune
