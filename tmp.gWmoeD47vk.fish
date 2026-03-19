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

set lnx_src $CBL_SRC_D/linux
set lnx_bld (tbf $lnx_src)-testing

kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/hwmon/macsmc-hwmon.o &| tee /tmp/build.log
set krnl_ret $pipestatus[1]

string match -er "declared with 'error' attribute: FIELD_PREP: value too large for the field" </tmp/build.log
switch "$krnl_ret $status"
    case '0 1'
        echo "Build succeeded but returning fail..."
        return 1 # reverse bisect
    case '1 0'
        echo "Build failed but returning success..."
        return 0
end
echo "Build failed without error message"
return 125
