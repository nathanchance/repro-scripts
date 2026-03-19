#!/usr/bin/env fish

__in_tree llvm
or return 128

cbl_patch_llvm
or return 128

set llvm_bld (tbf)-testing

tc_bld=$CBL_TC_BLD cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

function build_kernel
    set lnx_src $argv[1]
    set lnx_bld (tbf $lnx_src)-testing

    kmake \
        -C $lnx_src \
        ARCH=x86_64 \
        LLVM=$llvm_bld/final/bin/ \
        O=$lnx_bld \
        mrproper defconfig arch/x86/entry/vdso/vdso32/sigreturn.o
end

build_kernel $CBL_SRC_D/linux-next
or return 125

build_kernel $CBL_SRC_C/linux-next &| tee /tmp/build.log
set krnl_ret $pipestatus[1]

string match -er 'error: invalid register name' </tmp/build.log
switch "$krnl_ret $status"
    case '0 1'
        echo "Kernel build succeeded but returning fail for git bisect"
        return 1
    case '1 0'
        echo "Kernel build failed but returning success for git bisect"
        return 0
end
echo "Kernel build failed unexpectedly"
return 125
