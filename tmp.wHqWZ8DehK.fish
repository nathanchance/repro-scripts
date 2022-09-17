#!/usr/bin/env fish

cd $CBL_WRKTR/drm_vram_helper_mode_valid; or return 125

begin
    git cl -q
    and crl -o .config https://lore.kernel.org/all/35fb81bd-6020-f256-27cc-c2787b4dd9ef@intel.com/2-config-5.19.0-00144-gd88f8edb0952
    and kmake CCACHE=0 LLVM=1 olddefconfig bzImage
end; or return 125

set ret 0
for i in (seq 1 10)
    $CBL_GIT/boot-utils/boot-qemu.py -a x86_64 -k . -t 25s
    set ret (math $ret + $status)
end

echo "$ret"
test "$ret" = 0
