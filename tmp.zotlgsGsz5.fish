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
    ARCH=hexagon \
    -C $lnx_src \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/md/dm-thin.o &| string match -er '"Requested to preserve LCSSA, but it\'s already broken."'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
