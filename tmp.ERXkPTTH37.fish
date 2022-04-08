#!/usr/bin/env fish

in_container_msg -h; or exit

set results_log (mktemp -p $TMP_FOLDER)

for type in clang llvm
    set -l msg
    set -l var
    switch $type
        case clang
            set msg " CC=clang"
        case llvm
            set msg " LLVM=1"
            set var LLVM=1
    end

    for toolchain in clang-{nightly,1{4,3,2,1}}
        tuxmake \
            -a x86_64 \
            -C $CBL_SRC/linux-next \
            -k allmodconfig \
            -r podman \
            -t $toolchain \
            $var default
        if test $status -eq 0
            echo "$toolchain$msg: successful" >>$results_log
        else
            echo "$toolchain$msg: failed" >>$results_log
        end
    end
end

echo
cat $results_log
mail_msg $results_log
rm -f $results_log
