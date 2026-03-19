#!/usr/bin/env fish

in_tree kernel
or return 128

if not git merge-base --is-ancestor 894af4a1cde61c3401f237184fb770f72ff12df8 HEAD
    git diff v6.17-rc2..894af4a1cde61c3401f237184fb770f72ff12df8 | git ap
    or return 128
end

set lnx_bld (tbf)

set kmake \
    kmake \
    ARCH=x86_64 \
    (korg_llvm var) \
    O=$lnx_bld

begin
    remkdir $lnx_bld

    and $kmake defconfig

    and scripts/config \
        --file $lnx_bld/.config \
        -e CFI_CLANG \
        -e COMMON_CLK \
        -e CPUFREQ_DT \
        -e OF

    and $kmake olddefconfig vmlinux &| tee $lnx_bld/build.log

    and test "$pipestatus" = "0 0"
end
or set ret 125

git rh
if set -q ret
    return $ret
end

if string match -er 'warning: objtool: dev_pm_opp_find_level_(?:ceil|exact|floor)\+0x[0-9a-f]+: no-cfi indirect call!' <$lnx_bld/build.log
    return 1
end
