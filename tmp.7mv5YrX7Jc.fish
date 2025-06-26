#!/usr/bin/env fish

in_tree kernel
or return 128

if false
    if git merge-base --is-ancestor 104361217c2a2ab7d6a9de756952814af0a8a5ad HEAD
        git rv -n 104361217c2a2ab7d6a9de756952814af0a8a5ad
        or return 128
    end

    if git merge-base --is-ancestor 321a0fdf1337c5449a589b3d8186b23ecd36b240 HEAD
        git rv -n 321a0fdf1337c5449a589b3d8186b23ecd36b240
        or return 128
    end

    if git merge-base --is-ancestor 5cd05f3e23152b97e0be09938c78058395c3ee19 HEAD
        git rv -n 5cd05f3e23152b97e0be09938c78058395c3ee19
        or return 128
    end

    if git merge-base --is-ancestor 95a3645893bceb18475c3bea4afaf47d23d11ab6 HEAD
        git rv -n 95a3645893bceb18475c3bea4afaf47d23d11ab6
        or return 128
    end

    if git merge-base --is-ancestor 508bd94c3ad4bd8b5dba8280198ce1eb31eb625a HEAD
        git rv -n 508bd94c3ad4bd8b5dba8280198ce1eb31eb625a
        or return 128
    end

    if git merge-base --is-ancestor 17c1953567ebe08c88effb053df13744d0952cd1 HEAD; and not git merge-base --is-ancestor 97f4b999e0c894d3e48e318aa1130132031815b3 HEAD
        git cp -n 97f4b999e0c894d3e48e318aa1130132031815b3
        or return 128
    end
end

function run_test
    set bld (tbf)-testing

    kmake \
        ARCH=arm64 \
        $argv \
        O=$bld \
        mrproper virtconfig Image.gz
    or begin
        git rh
        exit 125
    end

    kboot -a arm64 -k $bld -t 45s &| string match -er 'WARNING: CPU: 0 PID: 0 at init/main.c:\d+ start_kernel\+'
    switch "$pipestatus"
        case '0 1'
            return 0
        case '0 0'
            return 1
    end
    return 125
end

run_test (korg_gcc var arm64)
or begin
    git rh
    return 125
end

run_test (korg_llvm var)
set ret $status
git rh
return $ret
