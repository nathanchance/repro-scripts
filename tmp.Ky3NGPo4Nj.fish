#!/usr/bin/env fish

if false
set llvm_src $CBL_SRC/llvm-project
set llvm_bld $TMP_BUILD_FOLDER/llvm-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --llvm-folder $llvm_src \
    --projects "clang;lld" \
    --targets X86; or return 125
end

set lnx_src $CBL_SRC/linux
set lnx_bld $TMP_BUILD_FOLDER/linux-bisect

set bld_log $TMP_FOLDER/build.log

rm -fr $lnx_bld $bld_log
mkdir -p $lnx_bld
crl -o $lnx_bld/.config https://github.com/archlinux/svntogit-packages/raw/packages/linux/trunk/config
$lnx_src/scripts/config --file $lnx_bld/.config -d DEBUG_INFO_DWARF5 -e DEBUG_INFO_DWARF4
make \
    -skj(nproc) \
    -C $lnx_src \
    LLVM=-15 \
    PAHOLE=$TMP_FOLDER/pahole/build/pahole \
    O=$lnx_bld \
    olddefconfig all &| tee $bld_log
if test $pipestatus[1] -eq 0
    if grep -Eq "die__process_unit: DW_TAG_label .* not handled" $bld_log
        return 1
    else
        return 0
    end
else
    return 125
end
