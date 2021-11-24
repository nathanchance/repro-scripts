#!/usr/bin/env fish

set tc_bld $CBL_GIT/tc-build

set fish_trace 1

$tc_bld/build-llvm.py \
    --assertions \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --no-update \
    --projects "clang;lld" \
    --targets X86; or exit 125

set -e fish_trace

set lnx $CBL_SRC/linux-next
set llvm_bin $tc_bld/build/llvm/stage1/bin
set kmake_args -C $lnx LLVM=1 LLVM_IAS=1

# Build must pass without CONFIG_FRAME_WARN
echo "CONFIG_FRAME_WARN=0" >$lnx/allmod.config
PO=$llvm_bin kmake $kmake_args KCONFIG_ALLCONFIG=1 distclean allmodconfig drivers/staging/greybus/audio_topology.o; or exit 125

# Reverse bisect so good is bad and bad is good
PO=$llvm_bin kmake $kmake_args distclean allmodconfig drivers/staging/greybus/audio_topology.o
if test $status -eq 0
    exit 1
else
    exit 0
end
