#!/usr/bin/env fish

cbl_clone_repo linux llvm-project tc-build

set llvm_src $CBL_SRC/llvm-project
set lnx_src $CBL_SRC/linux

set workdir (mktemp -d -p $TMP_FOLDER)
set llvm_bld $workdir/build/llvm
set lnx_bld $workdir/build/linux
set llvm_install $workdir/install/llvm
set logs $workdir/logs

set bld_llvm \
    $CBL_GIT/tc-build/build-llvm.py \
    --build-folder $llvm_bld \
    --llvm-folder $llvm_src \
    --no-ccache \
    --projects '"clang;lld"' \
    --targets X86

mkdir -p $logs
hyperfine \
    --command-name "`build-llvm.py`" \
    --command-name "`build-llvm.py --pgo kernel-defconfig`" \
    --command-name "`build-llvm.py --lto thin --pgo kernel-defconfig`" \
    --export-markdown $logs/llvm.log \
    --runs 1 \
    --shell fish \
    "$bld_llvm --install-folder $llvm_install/normal" \
    "$bld_llvm --install-folder $llvm_install/pgo --pgo kernel-defconfig" \
    "$bld_llvm --install-folder $llvm_install/pgo-thinlto --lto thin --pgo kernel-defconfig"; or return

for distro in arch debian fedora opensuse
    set config $workdir/x86_64-$distro.config

    if not test -f $config
        switch $distro
            case arch
                crl -o $config https://github.com/archlinux/svntogit-packages/raw/packages/linux/trunk/config

            case debian
                set deb_workdir (mktemp -d -p $workdir)
                set deb_url http://ftp.us.debian.org/debian/pool/main/l/linux-signed-amd64/linux-image-5.18.0-2-amd64_5.18.5-1_amd64.deb

                pushd $deb_workdir
                crl -O $deb_url
                ar x (basename $deb_url)
                tar xJf data.tar.xz
                mv -v boot/config-*-amd64 $config
                popd
                rm -fr $deb_workdir

                $lnx_src/scripts/config \
                    --file $config \
                    -d SYSTEM_TRUSTED_KEYS \
                    -e ANDROID_BINDER_IPC

            case fedora
                crl -o $config https://src.fedoraproject.org/rpms/kernel/raw/rawhide/f/kernel-x86_64-fedora.config

            case opensuse
                crl -o $config https://github.com/openSUSE/kernel-source/raw/master/config/x86_64/default
        end
    end

    hyperfine \
        --command-name LLVM \
        --command-name "PGO LLVM" \
        --command-name "PGO + ThinLTO LLVM" \
        --export-markdown $logs/$distro.log \
        --parameter-list type normal,pgo,pgo-thinlto \
        --prepare "rm -fr $lnx_bld; and mkdir -p $lnx_bld; and cp $config $lnx_bld/.config" \
        --runs 1 \
        --shell fish \
        "kmake -C $lnx_src ARCH=x86_64 CCACHE=0 LLVM=$llvm_install/{type}/bin/ O=$lnx_bld olddefconfig all"; or return
end

echo "Files are available in: $logs"
