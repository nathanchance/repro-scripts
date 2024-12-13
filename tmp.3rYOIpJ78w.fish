#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

set kmake_cmd \
    $PYTHON_SCRIPTS_FOLDER/kmake.py \
    ARCH=powerpc \
    (korg_gcc var powerpc64) \
    O=$bld

prep_config $CBL_LKT/configs/fedora/ppc64le.config $bld

$kmake_cmd olddefconfig kernel/padata.o
or return 125

$kmake_cmd W=e kernel/padata.o &| grep -P "include/linux/fortify-string.h:[0-9]+:[0-9]+: error: '__builtin_memcpy' reading between 257 and 536870904 bytes from a region of size 256"
set ret $pipestatus
switch "$ret"
    case "0 1" "1 0"
        return $ret[1]
end
return 125
