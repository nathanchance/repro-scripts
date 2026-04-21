#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing
remkdir $lnx_bld

set lnx_boot_log (mktemp -p $lnx_bld --suffix=.log)

kmake \
    ARCH=arm64 \
    (korg_gcc var arm64) \
    O=$lnx_bld \
    mrproper virtconfig Image.gz
or return 125

kboot \
    -a arm64 \
    -k $lnx_bld \
    -t 30s &| tee $lnx_boot_log
set kboot_ret $pipestatus[1]

string match -er 'WARNING: arch/arm64/kernel/cpufeature\.c:\d+ at init_cpu_features' <$lnx_boot_log
set strm_ret $status

switch "$kboot_ret $strm_ret"
    case '0 1'
        return 0
    case '0 0'
        return 1
end
return 128
