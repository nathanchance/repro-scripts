#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if git merge-base --is-ancestor 9e5470e7d6ea1ad4fe25a9416706d769e41a03c1 HEAD
    and not git merge-base --is-ancestor c43f828d59672b4844a7409e4660b9f8f509da35 HEAD
    git cherry-pick -n c43f828d59672b4844a7409e4660b9f8f509da35
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

# set lnx_src $CBL_SRC_C/linux-stable-6.12
set lnx_src $CBL_SRC_C/linux-next
set lnx_bld (tbf)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    KCFLAGS=-Wno-error \
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

kboot -k $lnx_bld -t 20s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
