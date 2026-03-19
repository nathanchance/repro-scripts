#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if git merge-base --is-ancestor bae8f1336db6a7f3288a7dcf253f2d484743b257 HEAD
    and not git merge-base --is-ancestor ed5bd23867eacaa3789060f9250ba6fcece2a3de HEAD
    git rv -n bae8f1336db6a7f3288a7dcf253f2d484743b257
    or return 128
end

if git merge-base --is-ancestor d74d841b65dc5ecc1adb87f94ee5c8073984e130 HEAD
    if git merge-base --is-ancestor ab9b23c446531f5d9f081123c9f2fde4e8a334eb HEAD
        git rv -n ab9b23c446531f5d9f081123c9f2fde4e8a334eb
        or return 128
    end

    git rv -n d74d841b65dc5ecc1adb87f94ee5c8073984e130
    or return 128
end

if git merge-base --is-ancestor 16d73839b1a5393ae094d709a0eef2b89cb3735f HEAD
    git rv -n 16d73839b1a5393ae094d709a0eef2b89cb3735f
    or return 128
end

if git merge-base --is-ancestor a757f23404c594f4a48b4ddb6625f88b349d11d5 HEAD
    git rv -n a757f23404c594f4a48b4ddb6625f88b349d11d5
    or return 128
end

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
if set -q ret
    return $ret
end

set lnx_src $CBL_SRC_C/linux-stable-6.12
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld

begin
    $kmake mrproper defconfig

    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d LTO_NONE \
        -e LTO_CLANG_THIN \
        -e CFI_CLANG

    and $kmake olddefconfig bzImage
end
or return 125

kboot \
    -a x86_64 \
    -k $lnx_bld \
    -t 30s &| tee /tmp/boot.log
set kboot_ret $pipestatus[1]
switch $kboot_ret
    case 0
        return 0
    case 124
        return 1
end
return 125

string match -er 'kernel BUG at kernel/entry/common\.c:\d+!' </tmp/boot.log
switch "$kboot_ret $status"
    case '0 1'
        return 0
    case '124 0'
        return 1
end
return 125
