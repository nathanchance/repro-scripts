#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

podcmd $CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects '"clang;lld"' \
    --show-build-commands \
    --targets '"ARM;X86"'; or exit 125

podcmd -e CCACHE=0 -s -v $build/stage1:/tc kmake -C $CBL_SRC/linux-next ARCH=arm LLVM=1 distclean multi_v5_defconfig kernel/sched/core.o
exit
# &| grep "error: out of range pc-relative fixup value"
set pipe $pipestatus

if test $pipe[1] -eq 0
    exit 0
else
    if test $pipe[2] -eq 0
        exit 1
    else
        exit 125
    end
end
