#!/usr/bin/env fish

in_kernel_tree; or exit

if test (count $argv) -eq 0
    print_error (basename (status filename))" requires at least one argument!"
    exit 1
end

for arg in $argv
    set arch $arg
    set log (mktemp --suffix=.log)

    echo "Build log: $log"
    echo

    for llvm_version in 1{1,2,3,4} android
        rm -fr .build/$arch

        echo "llvm-$llvm_version build log:" >>$log

        podcmd nathan/llvm-$llvm_version kmake ARCH=$arch LLVM=1 O=.build/$arch allmodconfig all &| tee -a $log
        set make_result $status

        # Clean up logs
        sed -i -e "s,\x1B\[[0-9;]*[a-zA-Z],,g" -e 's/[ \t]*$//' $log
        dos2unix -f $log

        if test $make_result -eq 0
            set make_result success
        else
            set make_result failed
        end

        echo "llvm-$llvm_version result: $make_result" >>$log
        echo >>$log
    end

    mail_msg $log
    rm -f $log
end
