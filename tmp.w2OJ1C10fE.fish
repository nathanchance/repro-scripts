#!/usr/bin/env fish

set log (mktemp -p $TMP_FOLDER --suffix=.log)

for llvm_ver in 11 12 13 14 nightly
    for llvm in 0 1
        for assembler in gnu llvm
            set -l make_vars

            switch $llvm
                case 0
                case 1
                    set -a make_vars LLVM=1
            end

            switch $assembler
                case gnu
                    set -a make_vars LLVM_IAS=0
                case llvm
            end

            tuxmake \
                -a arm64 \
                -C $CBL_SRC/linux \
                -k allmodconfig \
                -r podman \
                -t clang-$llvm_ver \
                $make_vars \
                default
            if test $status -eq 0
                set result successful
            else
                set result failed
            end

            set build "clang-$llvm_ver LLVM=$llvm"
            switch $assembler
                case gnu
                    set -a build LLVM_IAS=0
                case llvm
                    set -a build LLVM_IAS=1
            end
            echo "$build $result" | tee -a $log
        end
    end
end

mail_msg $log

echo
cat $log

rm -fr $log
