#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if not grep -q "#include <cstdint>" llvm/include/llvm/Support/Signals.h
    git cp -n ff1681ddb303223973653f7f5f3f3435b48a1983
    or return 128
end

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

prep_config https://download.01.org/0day-ci/archive/20250301/202503011220.Y2e5vz4w-lkp@intel.com/config $lnx_bld

# ensure KMSAN does not mess anything up
$lnx_src/scripts/config \
    --file $lnx_bld/.config \
    -d KMSAN
or return 125

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig drivers/bluetooth/hci_vhci.o &| tee /tmp/build.log &| grep -F 'drivers/bluetooth/hci_vhci.o: warning: objtool:'
switch "$pipestatus"
    case '0 0 0'
        return 1
    case '0 0 1'
        return 0
end
return 125
