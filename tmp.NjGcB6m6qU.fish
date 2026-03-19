#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

kmake \
    ARCH=powerpc \
    (korg_gcc var powerpc64) \
    O=$lnx_bld \
    mrproper ppc64le_guest_defconfig zImage.epapr
or set ret 125
git rh
set -q ret
and return $ret

U=0 kboot -a ppc64le -k $lnx_bld -t 30s &| tee /tmp/boot.log
test $pipestatus[1] -eq 0
or return 125

string match -er 'WARNING:(?: CPU: \d+ PID: \d+ at)? kernel/locking/mutex\.c:\d+ (?:at )?mutex_lock\+0x[[:xdigit:]]+' </tmp/boot.log
test $status -eq 1
