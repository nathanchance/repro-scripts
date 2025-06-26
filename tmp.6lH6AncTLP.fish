#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if cbl_bld_llvm_fast \
        --build-folder $llvm_bld \
        --targets Mips (get_host_llvm_target)
    set lnx_src $CBL_SRC_C/linux-next
    set lnx_bld (tbf $lnx_src)-testing

    kmake \
        -C $lnx_src \
        ARCH=mips \
        LLVM=$llvm_bld/final/bin/ \
        O=$lnx_bld \
        mrproper malta_defconfig arch/mips/kernel/genex.o &| string match -er '<instantiation>:\d+:\d+: error: expected an immediate'
    switch "$pipestatus"
        case '1 0'
            return 0 # reverse bisect
        case '0 1'
            return 1
    end
end

return 125
