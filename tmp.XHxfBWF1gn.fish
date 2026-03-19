#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

git -C $CBL_SRC_P/linux-next

kmake \
    ARCH=riscv \
    LLVM=1 \
    O=$lnx_bld \
    mrproper defconfig drivers/usb/core/devio.o &| string match -er 'MI\->getOpcode\(\) == TargetOpcode::COPY && "start of copy chain MUST be COPY"'
set ret $pipestatus
git rh
switch "$ret"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
