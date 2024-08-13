#!/usr/bin/env fish

in_kernel_tree
or return 128

begin
    prep_config $CBL_LKT/configs/opensuse/ppc64le.config
    and kmake ARCH=powerpc (korg_gcc var powerpc64) olddefconfig zImage.epapr
end
or exit 125

kboot -a ppc64le --gh-json-file /tmp/boot-utils.json -t 40s
switch $status
    case 0
        return 0
    case 124
        return 1
    case '*'
        return 125
end
