#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

git cp -n 894af4a1cde61c3401f237184fb770f72ff12df8
or return 128

prep_config https://download.01.org/0day-ci/archive/20251009/202510092124.O2IX0Jek-lkp@intel.com/config $lnx_bld
scripts/config --file $lnx_bld/.config -e CFI_CLANG

kmake \
    ARCH=x86_64 \
    (korg_llvm var) \
    O=$lnx_bld \
    olddefconfig vmlinux &| tee /tmp/build.log
set kret $pipestatus[1]

git rh

string match -er 'warning: objtool: rcar_pcie_probe\+0x[[:xdigit:]]+: no-cfi indirect call!' </tmp/build.log
switch "$kret $status"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 125
