#!/usr/bin/env fish

git cl -q
if git cp -n 4abff6d48dbc
    kmake \
        -C $CBL_SRC/linux \
        KCONFIG_ALLCONFIG=(echo CONFIG_WERROR=n | psub) \
        LLVM=1 \
        PO=$TMP_BUILD_FOLDER/llvm/stage1/bin/ \
        allmodconfig security/tomoyo/load_policy.o
    if test $status -eq 0
        echo "build succeeded, returning 1"
        set ret 1
    else
        echo "build failed, returning 0"
        set ret 0
    end
else
    echo "git cherry-pick failed, revision is untestable, returning 125"
    set ret 125
end

git rh
return $ret
