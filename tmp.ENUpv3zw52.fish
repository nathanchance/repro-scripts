#!/usr/bin/env fish

set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-testing

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets X86; or return 125

cd $CBL_SRC/linux; or return
git cl -q
and crl -o .config https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/linux/trunk/config
and scripts/config -e ZERO_CALL_USED_REGS
and kmake INSTALL_MOD_PATH=rootfs INSTALL_MOD_STRIP=1 LLVM=$llvm_bld/stage1/bin/ olddefconfig all modules_install
and cbl_gen_arch_initrd
