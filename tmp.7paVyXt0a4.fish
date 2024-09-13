#!/usr/bin/env fish

if not test -e llvm/CMakeLists.txt
    print_error "Not in an LLVM tree?"
    return 128
end

set llvm_bld (tbf)-bisect

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder . \
    --projects clang lld \
    --quiet-cmake \
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-bisect

prep_config https://download.01.org/0day-ci/archive/20240829/202408290219.BrPO8twi-lkp@intel.com/config $lnx_bld
or return 125

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    olddefconfig drivers/platform/x86/ideapad-laptop.o &| grep -F 'warning: objtool: .text.fan_mode_show: unexpected end of section'
set ret $pipestatus
if git bisect log &>/dev/null # bisecting
    switch $ret[1]
        case 0
            return $ret[2]  # reverse bisect
        case "*"
            return 125
    end
else
    switch "$ret"
        case "0 1"
            return 0
        case "0 0"
            return 1
        case "*"
            return 125
    end
end
