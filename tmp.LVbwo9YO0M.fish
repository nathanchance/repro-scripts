#!/usr/bin/env fish

if false
    if not test -e llvm/CMakeLists.txt
        print_error "Not in an LLVM tree?"
        return 1
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
end

function perform_test
    set lnx_src $NVME_SRC_FOLDER/common-android-multi/common-mainline
    set lnx_bld (tbf $lnx_src)-bisect

    # Just gki_defconfig
    prep_config $NVME_FOLDER/triage/android-mainline-boot-failure.config $lnx_bld
    or return 125

    kmake \
        -C $lnx_src \
        ARCH=x86_64 \
        $argv \
        O=$lnx_bld \
        olddefconfig bzImage
    or return 125

    U=0 kboot -a x86_64 -k $lnx_bld -t 20s
    switch $status
        case 0
            return 0
        case 124
            return 1
        case '*'
            return 125
    end
end

perform_test (korg_llvm var 18)
or return

perform_test (korg_llvm var)
