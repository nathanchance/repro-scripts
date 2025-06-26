#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

set good_lnx_src $CBL_SRC_C/linux
set good_lnx_bld (tbf $good_lnx_src)-testing

set bad_lnx_src $CBL_SRC_D/linux-next
if test (git -C $bad_lnx_src sha) != f6bff7827a48e59cff1ef98aae72452d65174e0c
    print_error "$bad_lnx_src not checked out @ f6bff7827a48e59cff1ef98aae72452d65174e0c?"
    return 128
end
set bad_lnx_bld (tbf $bad_lnx_src)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets RISCV (get_host_llvm_target)
or return 125

set kmake \
    kmake \
    ARCH=riscv \
    LLVM=$llvm_bld/final/bin/ \
    mrproper defconfig net/socket.o

$kmake -C $good_lnx_src O=$good_lnx_bld
or return 125

$kmake -C $bad_lnx_src O=$bad_lnx_bld &| string match -er 'MI->getOpcode\(\) == TargetOpcode::COPY && "start of copy chain MUST be COPY"'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
