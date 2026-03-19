#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

function get_configs
    printf 'CONFIG_%s=y\n' \
        EFI \
        ACPI \
        ACPI_APEI \
        ACPI_APEI_GHES \
        CRASH_DUMP \
        KEXEC_FILE \
        KASAN \
        WERROR
end

set kmake \
    kmake \
    ARCH=arm64 \
    O=$lnx_bld \
    mrproper allnoconfig drivers/acpi/apei/ghes.o

$kmake (korg_llvm var 18) KCONFIG_ALLCONFIG=(get_configs | psub)
or return

$kmake (korg_llvm var 17) KCONFIG_ALLCONFIG=(get_configs | psub) &| string match -er "error: stack frame size \(\d+\) exceeds limit \(2048\) in 'ghes_do_proc'"
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
