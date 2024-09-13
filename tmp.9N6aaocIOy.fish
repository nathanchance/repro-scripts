#!/usr/bin/env fish

in_kernel_tree
or return 128

set lnx_bld (tbf)-bisect

set kmake \
    $PYTHON_SCRIPTS_FOLDER/kmake.py \
    ARCH=powerpc \
    (korg_gcc var powerpc64 10) \
    O=$lnx_bld \
    olddefconfig arch/powerpc/kvm/

set sc \
    scripts/config \
    --file \
    $lnx_bld/.config

begin
    prep_config https://github.com/openSUSE/kernel-source/raw/master/config/ppc64le/default $lnx_bld
    and $sc --disable DEBUG_INFO_BTF
end
or return 128

begin
    $sc --disable CPUMASK_OFFSTACK \
        --set-val NR_CPUS 2048
    and $kmake
    and $sc --enable CPUMASK_OFFSTACK \
            --set-val NR_CPUS 8192
end
or return 125

$kmake &| grep -P 'arch/powerpc/kvm/[a-z0-9_]+\.S:[0-9]+: Error: operand out of range \(0x[0-9a-f]+ is not between 0xffffffffffff8000 and 0x7ff'
set ret $pipestatus

if git bisect log &>/dev/null
    set bisect true
end

switch "$ret"
    case "0 1"
        # Return "bad" if bisecting, return "good" if not
        if set -q bisect
            return 1
        else
            return 0
        end

    case "1 0"
        # Return "good" if bisecting, return "bad" if not
        if set -q bisect
            return 0
        else
            return 1
        end
end

return 125
