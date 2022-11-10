#!/usr/bin/env fish

set lnx_git $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-benchmarking
set tip_src $CBL_WRKTR/tip
set mainline_src $CBL_WRKTR/mainline

in_container_msg -h; or return
cbl_clone_repo linux
upd tuxmake
if not command -q hyperfine; and not test -x $BIN_FOLDER/hyperfine
    upd hyperfine
end
if command -q podman
    set runtime podman
else if command -q docker
    set runtime docker
else
    print_error "Neither podman nor docker could be found but one is required!"
    return 1
end

begin
    git -C $lnx_git ru origin
    and git -C $lnx_git f https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
    and rm -fr $mainline_src $tip_src
    and git -C $lnx_git worktree prune
    and git -C $lnx_git worktree add --detach $mainline_src origin/master
    and git -C $lnx_git worktree add --detach $tip_src FETCH_HEAD
end; or return

hyperfine \
    --command-name "mainline @ "(git -C $mainline_src kf) \
    --command-name "tip @ "(git -C $tip_src kf) \
    --parameter-list src $mainline_src,$tip_src \
    --prepare "rm -rf $lnx_bld" \
    --runs 3 \
    --shell fish \
    --warmup 1 \
    "tuxmake -a x86_64 -b $lnx_bld -C {src} -k allyesconfig -r $runtime -t llvm-15 default"

rm -fr $mainline_src $tip_src
git -C $lnx_git worktree prune
