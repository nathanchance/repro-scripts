#!/usr/bin/env fish

set results_log (mktemp -p $TMP_FOLDER)
for lnx_ver in 5.1{7,6,5}
    for arch in arm64 x86_64
        for llvm_img in llvm-1{1,2,3,4,5}
            dbxe $llvm_img -- fish -c "'git cl -q; and kmake -C $CBL_WRKTR/werror-$lnx_ver ARCH=$arch LLVM=1 allmodconfig all'"
            if test $status -eq 0
                echo "$lnx_ver $arch $llvm_img: successful" >>$results_log
            else
                echo "$lnx_ver $arch $llvm_img: failed" >>$results_log
            end
        end
    end
end
echo
cat $results_log
mail_msg $results_log
rm -f $results_log
