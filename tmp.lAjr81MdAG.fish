#!/usr/bin/env fish

if contains -- --no-llvm $argv
    set llvm_bld (tbf llvm-project)-testing
else
    in_tree llvm
    or return 128

    set llvm_bld (tbf)-testing

    git cherry-pick -n 7e44305041d96b064c197216b931ae3917a34ac1
    or return 128

    if not git merge-base --is-ancestor 40b4fd7a3e81d32b29364a1b15337bcf817659c0 HEAD
        git cherry-pick -n 40b4fd7a3e81d32b29364a1b15337bcf817659c0
        or return 128
    end

    cbl_bld_llvm_fast \
        --build-folder $llvm_bld \
        --targets PowerPC (get_host_llvm_target)
    or set ret 125
    git rh
    set -q ret
    and return $ret
end

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

prep_config $CBL_LKT/configs/fedora/ppc64le.config $lnx_bld

kmake \
    -C $lnx_src \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc64le-linux-gnu- \
    KCFLAGS='-mllvm -ppc-global-merge=false -Wno-error=unused-command-line-argument' \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig zImage.epapr
or return 125

kboot -a ppc64le -k $lnx_bld -t 45s &| string match -er 'BPF: Invalid offset'
switch "$pipestatus"
    case '0 0'
        return 1
    case '0 1'
        return 0
end
return 125
