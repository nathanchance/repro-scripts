#!/usr/bin/env fish

in_tree kernel
or return 128

set bld (tbf)-testing

if not test -f arch/mips/configs/repro.config
    echo 'CONFIG_RELOCATABLE=y
CONFIG_RELOCATION_TABLE_SIZE=0x00200000
CONFIG_RANDOMIZE_BASE=y' >arch/mips/configs/repro.config
end

kmake \
    ARCH=mips \
    (korg_gcc var mips) \
    O=$bld \
    mrproper {malta_def,repro.}config vmlinux
or return 125

kboot -k $bld -t 25s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
