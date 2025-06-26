#!/usr/bin/env fish

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

if not grep -q "#include <cstdint>" llvm/include/llvm/Support/Signals.h
    git cp -n ff1681ddb303223973653f7f5f3f3435b48a1983
    or return 128
end

$CBL_GIT/tc-build/build-llvm.py \
    --build-folder $llvm_bld \
    --build-stage1-only \
    --build-targets distribution \
    --llvm-folder . \
    --projects clang lld \
    --quiet-cmake \
    --show-build-commands \
    --targets X86 (get_host_llvm_target)
or set ret 125
git rh
set -q ret
and return $ret

set lnx_src $CBL_SRC_D/linux-next
set lnx_bld (tbf $lnx_src)-testing

if not test -f $lnx_src/kernel/configs/repro.config
    echo 'CONFIG_AMD_MEM_ENCRYPT=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_TRAP is not set
# CONFIG_UBSAN_BOUNDS is not set
# CONFIG_UBSAN_SHIFT is not set
# CONFIG_UBSAN_DIV_ZERO is not set
# CONFIG_UBSAN_UNREACHABLE is not set
# CONFIG_UBSAN_SIGNED_WRAP is not set
CONFIG_UBSAN_BOOL=y
CONFIG_UBSAN_ENUM=y
# CONFIG_UBSAN_ALIGNMENT is not set
# CONFIG_WERROR is not set' >$lnx_src/kernel/configs/repro.config
end

kmake \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper {def,repro.}config vmlinux &| grep -F "Absolute reference to symbol '.data' not permitted in .head.text"
switch "$pipestatus"
    case '0 1'
        return 1 # reverse bisect
    case '1 0'
        return 0
end
return 125
