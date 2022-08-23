#!/usr/bin/env fish

in_container_msg -h; or exit

set results_log (mktemp -p $TMP_FOLDER)

set wrktr $CBL_WRKTR/CONFIG_WERROR
set lnx_mainline $CBL_SRC/linux
set lnx_stable $CBL_SRC/linux-stable

# Clean up any previous instances of this testing
rm -fr $wrktr
if test -d $lnx_mainline
    git -C $lnx_mainline worktree prune
end
if test -d $lnx_stable
    git -C $lnx_stable worktree prune
end

for lnx_ver in mainline 5.1{9,5}
    set lnx_src $wrktr/$lnx_ver

    if not test -d $lnx_src
        mkdir -p (dirname $lnx_src)

        switch $lnx_ver
            case 5.15 5.19
                cbl_clone_repo linux-stable

                set branch linux-$lnx_ver.y
                set repo $CBL_SRC/linux-stable

                if test "$lnx_ver" = 5.19
                    set patch_dir stable
                else
                    set patch_dir $lnx_ver
                end
            case mainline
                cbl_clone_repo linux

                set branch master
                set repo $CBL_SRC/linux
                set patch_dir mainline
        end
        git -C $repo remote update --prune origin
        git -C $repo worktree add --detach $lnx_src origin/$branch

        # Patch repo for known warnings
        cbl_clone_repo continuous-integration2
        git -C $lnx_src am $CBL_GIT/continuous-integration2/patches/$patch_dir/eab9100d9898cbd37882b04415b12156f8942f18.patch; or return
    end

    for arch in arm64
        for toolchain in llvm-(seq 16 -1 11)
            for build in allmodconfig allmodconfig_thinlto allyesconfig
                switch $build
                    case allmodconfig allyesconfig
                        set tuxmake_args \
                            --kconfig $build

                    case allmodconfig_thinlto
                        set tuxmake_args \
                            --kconfig allmodconfig \
                            --kconfig-add CONFIG_GCOV_KERNEL=n \
                            --kconfig-add CONFIG_KASAN=n \
                            --kconfig-add CONFIG_LTO_CLANG_THIN=y
                end

                set fish_trace 1
                tuxmake \
                    --directory $lnx_src \
                    --image $GHCR/$toolchain \
                    $tuxmake_args \
                    --runtime podman-local \
                    --target-arch $arch \
                    --toolchain llvm \
                    default
                set -e fish_trace
                if test $status -eq 0
                    echo "$lnx_ver $arch $build $toolchain: successful" >>$results_log
                else
                    echo "$lnx_ver $arch $build $toolchain: failed" >>$results_log
                end
            end
        end
    end
end
echo

# Clean up
rm -fr $wrktr
git -C $lnx_mainline worktree prune
git -C $lnx_stable worktree prune

# Results
cat $results_log
mail_msg $results_log
rm -f $results_log
