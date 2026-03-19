#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets Hexagon (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=hexagon \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bkd \
    mrproper allmodconfig net/netfilter/nf_conntrack_netlink.o &| string match -er 'Tmp == Is32 && "Register size mismatch"'
switch "$pipestatus"
    case '0 1' '1 0'
        return $pipestatus[1]
end
return 125
