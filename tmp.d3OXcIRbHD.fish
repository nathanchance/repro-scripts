#!/usr/bin/env fish

__in_tree llvm
or return 128

set lnx_src $CBL_SRC_D/linux-next
if test (git -C $lnx_src sha) != abc850e7616c91ebaa3f5ba3617ab0a104d45039
    __print_error "$lnx_src not checked out at abc850e7616c91ebaa3f5ba3617ab0a104d45039"
    return 128
end

set llvm_bld (tbf)-testing

cbl_patch_llvm
or return 128

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets PowerPC (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set lnx_bld (tbf $lnx_src)-testing

prep_config https://download.01.org/0day-ci/archive/20251125/202511250134.i0Jm8d7I-lkp@intel.com/config $lnx_bld

kmake \
    -C $lnx_src \
    ARCH=powerpc \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig kernel/rseq.o &| string match -er 'error: invalid operand for instruction'
switch "$pipestatus"
    case '0 1'
        echo Build succeeded without error, returning fail for git bisect...
        return 1
    case '1 0'
        echo Build failed with error, returning success for git bisect...
        return 0
end
echo Build failed without error, returning skip for git bisect...
return 125
