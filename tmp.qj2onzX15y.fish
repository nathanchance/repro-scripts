#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set build $TMP_FOLDER/build/llvm

$CBL_GIT/tc-build/build-llvm.py \
    --build-folder $build \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects "clang;lld" \
    --targets X86; or return 125

set lnx $CBL_SRC/linux

git -C $lnx cl -q
crl -o $lnx/.config https://lore.kernel.org/llvm/CAEQFVGYpPaE3cCxUBaiT97GU1i4Nr6yJdv6mU1kiCxqkLSMfBQ@mail.gmail.com/3-518_x86_defconfig
kmake -C $lnx ARCH=i386 LLVM=$build/stage1/bin/ LLVM_IAS=0 olddefconfig mm/maccess.o
if test $status -eq 0
    print_warning "Build succeeded but returning fail for git bisect"
    exit 1
else
    print_warning "Build failed but returning success for git bisect"
    exit 0
end
