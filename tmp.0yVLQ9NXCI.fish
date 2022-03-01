#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $llvm/build

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --show-build-commands \
    --targets "PowerPC;X86"; or exit 125

cd $CBL_SRC/linux; or exit 125
git cl -q; or exit 125
crl -o .config https://lore.kernel.org/all/f41550c7-26c0-cf81-7de9-aa924434a565@molgen.mpg.de/3-linux-5.17-rc4-rcu-dev-config.txt; or exit 125
scripts/config --set-val INITRAMFS_SOURCE '""'; or exit 125

# Everything needs to work with ld.bfd, otherwise the revision is chalked.
PO=$build/stage1/bin kmake \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc64le-linux-gnu- \
    LD=powerpc64le-linux-gnu-ld \
    LLVM=1 \
    LLVM_IAS=0 \
    disable-werror.config all; or exit 125
kboot -a ppc64le -t 45s; or exit 125

PO=$build/stage1/bin kmake \
    ARCH=powerpc \
    CROSS_COMPILE=powerpc64le-linux-gnu- \
    LLVM=1 \
    LLVM_IAS=0 \
    clean all; or exit 125
kboot -a ppc64le -t 45s
if test $status -eq 124
    echo
    echo "QEMU timed out but we are returned good for git bisect."
    exit 0
else
    echo
    echo "QEMU exited cleanly but we are returned bad for git bisect."
    exit 1
end
