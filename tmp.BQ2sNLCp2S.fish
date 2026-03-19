#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

set common_make_flags \
    ARCH=x86_64 \
    (korg_llvm var)

set j_flag -j(nproc)

set fish_trace 1

MAKEFLAGS="$j_flag $common_make_flags" tools/testing/ktest/config-bisect.pl -b $lnx_bld $NVME_FOLDER/triage/cbl-2134/config-{good,bad} $argv[1]
or return 128

kmake $common_make_flags O=$lnx_bld clean vmlinux
