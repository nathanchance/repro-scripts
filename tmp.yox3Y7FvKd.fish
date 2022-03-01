#!/usr/bin/env fish

set llvm_dir $CBL_SRC/llvm-project
set tmp_install (mktemp -d -p $TMP_FOLDER)

for ver_type in good bad
    switch $ver_type
        case bad
            set git_sha 536b9eb31e9333bcee3d20d694f7cb12d1ff3d89 # [DebugInfo][InstrRef] Add extra indirection for NRVO tests
        case good
            set git_sha 55c14d6dbfd8e7b86c15d2613fea3490078e2ae4 # [ELF] Simplify DynamicSection content computation. NFC
    end
    git -C $llvm_dir cl -q; or exit
    git -C $llvm_dir rh $git_sha; or exit

    $CBL_GIT/tc-build/build-llvm.py \
        --assertions \
        --build-folder $llvm_dir/build \
        --build-stage1-only \
        --check-targets clang ll{d,vm{,-unit}} \
        --install-folder $tmp_install/llvm-$ver_type \
        --install-stage1-only \
        --llvm-folder $llvm_dir \
        --projects "clang;lld" \
        --targets "PowerPC;X86" \
        --show-build-commands; or exit
end

echo
echo "Installs are available in $tmp_install"
echo

for ver_type in good bad
    set lnx $CBL_SRC/linux
    set out_dir $tmp_install/cbl-1594-$ver_type
    set cfg $out_dir/.config

    mkdir -p $out_dir
    crl -o $cfg https://lore.kernel.org/all/f41550c7-26c0-cf81-7de9-aa924434a565@molgen.mpg.de/3-linux-5.17-rc4-rcu-dev-config.txt; or exit 125
    $lnx/scripts/config --file $cfg --set-val INITRAMFS_SOURCE '""'; or exit 125

    PO=$tmp_install/llvm-$ver_type/bin kmake \
        -C $lnx \
        ARCH=powerpc \
        CROSS_COMPILE=powerpc64le-linux-gnu- \
        LLVM=1 \
        LLVM_IAS=0 \
        O=$out_dir \
        disable-werror.config all; or exit 125
    kboot -a ppc64le -k $out_dir -t 45s; or exit 125
end
