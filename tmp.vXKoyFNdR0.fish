#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_patch_llvm
or return 128

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets AArch64 ARM (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/acpi/apei/ghes.o &| string match -er "in 'ghes_do_proc' \[-Werror,-Wframe-larger-than\]"
switch "$pipestatus"
    case '0 1'
        echo Build succeeded but returning fail for git bisect...
        return 1
    case '1 0'
        echo Build failed but returning success for git bisect...
        return 0
end
echo Build failed but did not contain message?
return 125
