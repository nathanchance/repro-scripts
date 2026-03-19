#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

git fp -1 --stdout 6f110a5e4f99 mm/Kconfig | git ap
or return 128

kmake \
    ARCH=s390 \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    (korg_llvm var) \
    O=$lnx_bld \
    mrproper allmodconfig lib/test_bitmap.o &| string match -er "error: call to '__compiletime_assert_\d+' declared with 'error' attribute: BUILD_BUG_ON failed: !__builtin_constant_p\(~var\)"
set ret $pipestatus
git rh
switch "$ret"
    case '0 1'
        echo build succeeded as expected but returning fail for git bisect...
        return 1
    case '1 0'
        echo build failed as expected but returning success for git bisect...
        return 0
end
echo unexpected build failure?
return 125
