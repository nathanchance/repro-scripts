#!/usr/bin/env fish

set pkgname linux-debug

if git merge-base --is-ancestor 5a82223e0743fb36bcb99657772513739d1a9936 HEAD
    crl 'https://git.infradead.org/?p=users/dwmw2/linux.git;a=patch;h=9719039b3790e7b20cca2da57c2db60600749144' | git ap
    or return 128
end

cbl_bld_krnl_pkg $argv --localmodconfig --no-werror debug (korg_llvm var)
or set ret $status

if not set -q ret
    set pkg (tbf $pkgname)/$pkgname-*.pkg.tar.zst
    set user_host $USER@(string join . 147 75 51 231)
    set remote_dst (string replace $EXT_FOLDER $HOME $VM_FOLDER)/x86_64/arch/shared

    ssh $user_host "fish -c 'for pkg in $remote_dst/$pkgname-*.pkg.tar.zst; rm "'$pkg'"; or break; end'"
    and rsync --compress --compress-choice zstd --progress $pkg $user_host:$remote_dst

    set ret $status
end

git rh
bell

return $ret
