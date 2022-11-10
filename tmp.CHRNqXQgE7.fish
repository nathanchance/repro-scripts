#!/usr/bin/env fish

set lnx_git $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-benchmarking
set tip_src $CBL_WRKTR/tip
set mainline_src $CBL_WRKTR/mainline

in_container_msg -c; or return
cbl_clone_repo linux
command -q hypefine; or upd hyperfine

begin
    git -C $lnx_git ru origin
    and git -C $lnx_git f https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
    and rm -fr $mainline_src $tip_src
    and git -C $lnx_git worktree prune
    and git -C $lnx_git worktree add --detach $mainline_src origin/master
    and git -C $lnx_git worktree add --detach $tip_src FETCH_HEAD
end; or return

hyperfine \
    --command-name mainline \
    --command-name tip \
    --parameter-list src $mainline_src,$tip_src \
    --prepare "rm -rf $lnx_bld" \
    --runs 3 \
    --warmup 1 \
    "make -C {src} -skj$(nproc) ARCH=x86_64 LLVM=1 O=$lnx_bld allyesconfig all"

rm -fr $mainline_src $tip_src
git -C $lnx_git worktree prune
