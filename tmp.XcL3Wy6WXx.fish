#!/usr/bin/env fish

set lnx $CBL_SRC/linux-next
set cfg $lnx/.config

set configs \
    ppc64le_defconfig \
    powernv_defconfig \
    $CBL/llvm-kernel-testing/configs/debian/powerpc64le.config \
    https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-ppc64le-fedora.config \
    https://raw.githubusercontent.com/openSUSE/kernel-source/master/config/ppc64le/default

set kmake_args -C $lnx ARCH=powerpc CROSS_COMPILE=powerpc64le-linux-gnu- LLVM=1 LLVM_IAS=0

for config in $configs
    rm -rf $cfg
    if string match -q "https://*" $config
        crl -o $cfg $config
    else if string match -q "*/*" $config
        cp $config $cfg
    else
        kmake $kmake_args $config
    end
    if test -f "$cfg"
        $lnx/scripts/config --file $cfg -d BPF_PRELOAD -d DEBUG_INFO_BTF -d SYSTEM_TRUSTED_KEYS
    end

    kmake $kmake_args clean olddefconfig all; or exit 125
end

# bootk -a ppc64le -k $lnx -t 1m
