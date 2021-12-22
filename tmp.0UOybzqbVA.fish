#!/usr/bin/env fish

in_kernel_tree; or exit

if test (count $argv) -eq 0
    print_error (basename (status filename))" requires at least one argument!"
    exit 1
end

for arg in $argv
    switch $arg
        case --no-kasan
            set kasan false
        case '*'
            set -a arches $arg
    end
end

for arch in $arches
    set log (mktemp --suffix=.log)

    echo "Build log: $log"
    echo

    if test "$kasan" = false
        echo CONFIG_KASAN=n >allmod.config
        set kconfig_allconfig KCONFIG_ALLCONFIG=1
    else
        rm -f allmod.config
        set -e kconfig_allconfig
    end

    for llvm_version in 1{1,2,3,4} android
        set -l llvm_ias

        if test $arch = arm
            switch $llvm_version
                case 11 12
                    set llvm_ias CROSS_COMPILE=arm-linux-gnueabi- LLVM_IAS=0
            end
        end

        rm -fr .build/$arch

        echo "llvm-$llvm_version build log:" >>$log

        podcmd nathan/llvm-$llvm_version kmake ARCH=$arch LLVM=1 $llvm_ias $kconfig_allconfig O=.build/$arch allmodconfig all &| tee -a $log
        set make_result $pipestatus[1]

        if test $make_result -eq 0
            set make_result success
        else
            set make_result failed
        end

        echo "llvm-$llvm_version result: $make_result" >>$log
        echo >>$log
    end

    # Clean up logs
    sed -i -e "s,\x1B\[[0-9;]*[a-zA-Z],,g" -e 's/[ \t]*$//' $log
    dos2unix -f $log

    mail_msg $log
    rm -f $log
end
