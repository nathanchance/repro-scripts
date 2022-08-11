#!/usr/bin/env fish

set kmake_args \
    -C $CBL_SRC/linux \
    ARCH=x86_64 \
    LLVM=1 \
    O=build/x86_64

set kmake_targets \
    mrproper \
    allmodconfig
for i in (seq 30 32)
    set -a kmake_targets \
        drivers/gpu/drm/amd/amdgpu/../display/dc/dml/dcn$i/display_mode_vba_$i.o
end


echo "allmodconfig:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'

echo
echo "allmodconfig + CONFIG_GCOV_KERNEL=n:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_GCOV_KERNEL=n\nCONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'

echo
echo "allmodconfig + CONFIG_KASAN=n:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_KASAN=n\nCONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'

echo
echo "allmodconfig + CONFIG_KCOV=n:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_KCOV=n\nCONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'

echo
echo "allmodconfig + CONFIG_UBSAN=n:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_UBSAN=n\nCONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'
rg "SAN|(K|G)COV" $CBL_SRC/linux/build/x86_64/.config

echo
echo "allmodconfig + CONFIG_KASAN=n + CONFIG_KCSAN=y + CONFIG_UBSAN=n:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_KASAN=n\nCONFIG_UBSAN=n\nCONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'

echo
echo "allmodconfig + CONFIG_KASAN=n + CONFIG_KCSAN=n + CONFIG_UBSAN=n:"
echo

kmake \
    $kmake_args \
    KCONFIG_ALLCONFIG=(printf "CONFIG_KASAN=n\nCONFIG_KCSAN=n\nCONFIG_UBSAN=n\nCONFIG_WERROR=n\n" | psub) \
    $kmake_targets &| grep -E "warning:.*dml3[0-9]_ModeSupportAndSystemConfigurationFull" &| sed 's/.*warning: /warning: /g'
