#!/usr/bin/env fish

if not in_kernel_tree
    print_error "You need to be in a kernel tree to run this!"
    exit 1
end

for arch in arm64 x86_64
    for ver in 1{1,2,3,4}
        git cl -q
        podcmd $GHCR/llvm-$ver kmake ARCH=$arch LLVM=1 allmodconfig all; or exit
    end
end
