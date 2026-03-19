#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

set clang_21 $TMP_FOLDER/bolt-aarch64-issues/clang-21
if not test -e $clang_21
    print_error "$clang_21 not found?"
    return 128
end

cbl_patch_llvm
or return 128

if not git merge-base --is-ancestor f83a89c1b1ce78cfac1de1c72a03b234d2a844b6 HEAD
    if git merge-base --is-ancestor 52cf07116bf0a8cab87b0f55176d198bcaa02575 HEAD
        git cherry-pick -n f83a89c1b1ce78cfac1de1c72a03b234d2a844b6
    else
        git fp -1 --stdout f83a89c1b1ce78cfac1de1c72a03b234d2a844b6 | sed 's;BC.errs;errs;g' | git ap
    end
    or return 128
end

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --build-targets llvm-bolt \
    --projects bolt \
    --targets AArch64 ARM
or set ret 125
git rh
if set -q ret
    return $ret
end

$llvm_bld/final/bin/llvm-bolt \
    --instrument \
    --instrumentation-file=/tmp/clang.fdata \
    --instrumentation-file-append-pid \
    -o $llvm_bld/clang.inst \
    $clang_21

set remote nathan@10.0.1.253
set remote_workdir /home/$USER/tmp/bolt-aarch64-issues
set remote_clang_inst $remote_workdir/clang.inst

header "Testing clang-21"

ssh $remote $remote_workdir/clang-21 --version
or return 125

header "Testing clang.inst"
ssh $remote /usr/bin/rm -f $remote_clang_inst
rsync \
    --compress \
    --compress-choice zstd \
    --progress \
    $llvm_bld/clang.inst \
    $remote:$remote_clang_inst

ssh $remote $remote_clang_inst --version
switch $status
    case 0
        return 0
    case 132
        echo clang errored with illegal instruction
        return 1
end
