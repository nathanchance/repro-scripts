#!/usr/bin/env fish

in_tree llvm
or return 125

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
    O=$lnx_bld \
    mrproper allmodconfig net/ipv4/tcp_input.o &| string match -er 'Node2Index\[SU\.NodeNum\] > Node2Index\[PD\.getSUnit\(\)->NodeNum\] && "Wrong topological sorting"'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
