#!/usr/bin/env fish

set llvm_dir $CBL_WRKTR/D118663-llvm
set tmp_install (mktemp -d -p $TMP_FOLDER)

for ver_type in good bad
    switch $ver_type
        case bad
            set git_sha 850fd21b2cd12664875016883390216067eadab4 # [AArch64] Adds SUBS and ADDS instructions to the MIPeepholeOpt.
        case good
            set git_sha effd6dd63a65f201b4f8f1be6a025b0608604449 # [Clang][Sema] Add a missing regression test about Wliteral-range
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
        --targets "AArch64;ARM;X86" \
        --show-build-commands; or exit
end

echo
echo "Installs are available in $tmp_install"
echo

for ver_type in good bad
    cbl_lkt \
        --arches arm64 \
        --linux-src $CBL_WRKTR/D118663-linux \
        --llvm-prefix $tmp_install/llvm-$ver_type
end
