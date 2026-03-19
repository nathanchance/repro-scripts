#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_patch_llvm
or return 128

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets Hexagon (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set good_lnx_src $CBL_SRC_D/linux
set bad_lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $good_lnx_src)-testing
remkdir $lnx_bld
begin
    echo CONFIG_TRIM_UNUSED_KSYMS=n
    print_no_werror_cfgs
end >$lnx_bld/allmod.config

set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

set kmake \
    kmake \
    ARCH=hexagon \
    KCONFIG_ALLCONFIG=$lnx_bld/allmod.config \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig vmlinux

$kmake -C $good_lnx_src
or return 128

set llvm_maj (__get_llvm_ver_src $PWD | string split -f 1 .)
set artifact_dir /tmp/$llvm_maj
mkdir -p $artifact_dir
cp $lnx_bld/.config $artifact_dir/config-good
cp $lnx_bld/init/.main.o.cmd $artifact_dir/main.o.cmd-good

$kmake -C $bad_lnx_src &| tee $lnx_bld_log
set krnl_ret $pipestatus[1]

cp $lnx_bld/.config $artifact_dir/config-bad
cp $lnx_bld/init/.main.o.cmd $artifact_dir/main.o.cmd-bad

string match -er "ld\.lld: error: vmlinux\.a\(arch/hexagon/kernel/head\.o\):\(\.init\.text\+0x[0-9a-f]+\): relocation R_HEX_B22_PCREL out of range: \d+ is not in \[\-\d+, \d+\]; references 'memset'" <$lnx_bld_log
set strm_ret $status

switch "$krnl_ret $strm_ret"
    case '0 1'
        echo Build succeeded but returning fail for git bisect...
        return 1
    case '1 0'
        echo Build failed but returning success for git bisect...
        return 0
end
echo Build failed unexpectedly
return 125
