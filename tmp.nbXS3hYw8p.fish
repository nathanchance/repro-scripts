#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if git merge-base --is-ancestor 6f53f1c8d2bdd13e30da7d1b85ed6a3ae4c4a856 HEAD
    and not git merge-base --is-ancestor 94655dc8aec2f4e4b287e4c6ac829263f93e9740 HEAD
    git fp -1 --stdout 98164d4706115b3ed850be84bb4647c56d2b2eaf lld/ELF | git ap
    or return 128

    git fp -1 --stdout 94655dc8aec2f4e4b287e4c6ac829263f93e9740 lld/ELF | git ap
    or return 128
end

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets RISCV (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

function test_kernel
    set lnx_src $argv[1]
    if not test -d $lnx_src
        __print_error "$lnx_src does not exist?"
        exit 128
    end
    set lnx_bld (tbf $lnx_src)-testing

    kmake \
        -C $lnx_src \
        ARCH=riscv \
        KCONFIG_ALLCONFIG=(printf 'CONFIG_%s\n' GCOV_KERNEL=n LTO_CLANG_THIN=y TRIM_UNUSED_KSYMS=n WERROR=n | psub) \
        LLVM=$llvm_bld/final/bin/ \
        O=$lnx_bld \
        mrproper allmodconfig vmlinux
end

test_kernel $CBL_SRC_C/linux
or return 125

test_kernel $CBL_SRC_C/linux-next &| string match -er 'Assertion `j \+ 2 == skip'
switch "$pipestatus"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
