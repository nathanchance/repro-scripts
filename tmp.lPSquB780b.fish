#!/usr/bin/env fish

if test (uname -m) != x86_64
    print_error "This reproducer requires an x86_64 machine"
    return 128
end

in_tree llvm
or return 128

set lnx_src $CBL_SRC_D/linux-next
if not string match -qr X86_NATIVE_CPU <$lnx_src/arch/x86/Kconfig.cpu
    print_error "Linux tree does not have CONFIG_X86_NATIVE_CPU?"
    return 128
end

set llvm_bld (tbf)-testing

if string match -qr 'Constant \*ConstantFoldFP128\(long double \(\*NativeFP\)\(long double\)' <llvm/lib/Analysis/ConstantFolding.cpp
    git cherry-pick -n 40b4fd7a3e81d32b29364a1b15337bcf817659c0
    or return 128
end

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86
or set ret 125
git rh
if set -q ret
    return $ret
end

set lnx_bld (tbf $lnx_src)-testing
set kmake \
    $PYTHON_SCRIPTS_FOLDER/kmake.py \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/media/pci/saa7164/saa7164-core.o

$kmake KCONFIG_ALLCONFIG=(echo CONFIG_X86_NATIVE_CPU=n | psub)
or return 125

$kmake &| string match -er saa7164_irq
switch "$pipestatus"
    case '0 1'
        echo "result is good but returning bad"
        return 1
    case '1 0'
        echo "result is bad but returning good"
        return 0
end
echo "result is unexpected"
return 125
