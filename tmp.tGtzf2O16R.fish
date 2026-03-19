#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets AArch64 ARM (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

set kmake \
    kmake \
    -C $lnx_src \
    ARCH=arm64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld

begin
    $kmake mrproper virtconfig
    and $lnx_src/scripts/config \
        --file $lnx_bld/.config \
        -d LTO_NONE \
        -e LTO_CLANG_THIN
    and $kmake olddefconfig
end
or return 125

$kmake kernel/configs.o &| string match -er 'error in backend: Opening include file from SourceMgr without VFS'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
