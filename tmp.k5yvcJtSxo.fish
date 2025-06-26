#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if not contains -- --no-llvm $argv
    cbl_bld_llvm_fast \
        --build-folder $llvm_bld \
        --targets PowerPC (get_host_llvm_target)
    or return 125
end

if not set -q lnx_src
    set lnx_src $CBL_SRC_C/linux
end
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=powerpc \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper pmac32_defconfig vmlinux
or return 125

kboot -a ppc32_mac -k $lnx_bld -t 30s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
