#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build



# Build LLVM. If the build or tests fail, the revision is untestable.
podcmd $CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects '"clang;lld"' \
    --targets X86 \
    --show-build-commands; or exit 125



cd $CBL_SRC/linux-next; or exit 125



# defconfig plus KASAN choices should be fine
git cl -q

podcmd -s -v $build/stage1:/tc kmake LLVM=1 defconfig

scripts/config \
    -e KASAN \
    -d KASAN_OUTLINE \
    -e KASAN_INLINE \
    -e KASAN_VMALLOC

podcmd -s -v $build/stage1:/tc kmake LLVM=1 olddefconfig

rg "CONFIG_(KASAN|GCOV)" .config

podcmd -s -v $build/stage1:/tc kmake LLVM=1 bzImage; or exit 125

podcmd kboot -a x86_64 -t 3m; or exit 125



# defconfig plus GCOV choices should be fine
git cl -q

podcmd -s -v $build/stage1:/tc kmake LLVM=1 defconfig

scripts/config \
    -e GCOV_KERNEL \
    -e GCOV_PROFILE_ALL

podcmd -s -v $build/stage1:/tc kmake LLVM=1 olddefconfig

rg "CONFIG_(KASAN|GCOV)" .config

podcmd -s -v $build/stage1:/tc kmake LLVM=1 bzImage; or exit 125

podcmd kboot -a x86_64 -t 3m; or exit 125



# defconfig plus both GCOV and KASAN choices has issues
git cl -q

podcmd -s -v $build/stage1:/tc kmake LLVM=1 defconfig

scripts/config \
    -e GCOV_KERNEL \
    -e GCOV_PROFILE_ALL \
    -e KASAN \
    -d KASAN_OUTLINE \
    -e KASAN_INLINE \
    -e KASAN_VMALLOC

podcmd -s -v $build/stage1:/tc kmake LLVM=1 olddefconfig

rg "CONFIG_(KASAN|GCOV)" .config

if podcmd "echo | $build/stage1/bin/clang -flegacy-pass-manager -x c -c -o /dev/null -" &>/dev/null
    set lpm_flag -flegacy-pass-manager
    set npm_flag -fno-legacy-pass-manager
else
    set lpm_flag -fno-experimental-new-pass-manager
    set npm_flag -fexperimental-new-pass-manager
end

podcmd -s -v $build/stage1:/tc kmake KCFLAGS=$lpm_flag LLVM=1 bzImage; or exit 125

podcmd kboot -a x86_64 -t 3m



# defconfig plus both GCOV and KASAN choices has issues
git cl -q

podcmd -s -v $build/stage1:/tc kmake LLVM=1 defconfig

scripts/config \
    -e GCOV_KERNEL \
    -e GCOV_PROFILE_ALL \
    -e KASAN \
    -d KASAN_OUTLINE \
    -e KASAN_INLINE \
    -e KASAN_VMALLOC

podcmd -s -v $build/stage1:/tc kmake LLVM=1 olddefconfig

rg "CONFIG_(KASAN|GCOV)" .config

podcmd -s -v $build/stage1:/tc kmake KCFLAGS=$npm_flag LLVM=1 bzImage; or exit 125

podcmd kboot -a x86_64 -t 3m

set qemu_ret $status
if test $qemu_ret -eq 0
    exit 0
else if test $qemu_ret -eq 124
    exit 1
else
    exit 125
end
