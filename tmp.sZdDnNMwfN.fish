#!/usr/bin/env fish

in_container_msg -h; or exit

set results_log (mktemp -p $TMP_FOLDER)
for lnx_ver in next mainline 5.1{8,5}
    for arch in arm64 x86_64
        for toolchain in clang-{nightly,1{4,3,2,1}}
            tuxmake \
                -a $arch \
                -C $CBL_WRKTR/CONFIG_WERROR/$lnx_ver \
                -k allmodconfig \
                -r podman \
                -t $toolchain \
                LLVM=1 default
            if test $status -eq 0
                echo "$lnx_ver $arch $toolchain: successful" >>$results_log
            else
                echo "$lnx_ver $arch $toolchain: failed" >>$results_log
            end
        end
    end
end
echo
cat $results_log
mail_msg $results_log
rm -f $results_log
