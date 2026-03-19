#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

if git merge-base --is-ancestor 59953303827eceb06d486ba66cc0d71f55ded8ec HEAD
    and not git merge-base --is-ancestor 59bfa6408214b6533d8691715cf5459e89b45b89 HEAD
    git cherry-pick -n 59bfa6408214b6533d8691715cf5459e89b45b89
    or return 128
end

kmake \
    ARCH=x86_64 \
    (korg_llvm var) \
    O=$lnx_bld \
    mrproper allmodconfig drivers/scsi/qla2xxx/qla2xxx.o &| string match -er 'Error 139'
set ret $pipestatus
git rh
switch "$ret"
    case '0 1'
        return 0
    case '1 0'
        return 1
end
return 125
