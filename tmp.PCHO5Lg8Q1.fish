#!/usr/bin/env fish

cd $CBL_SRC/linux-next

if git pull --no-{edit,ff} https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git driver-core-next
    rm -fr build
    if kmake ARCH=um CROSS_COMPILE=/usr/bin/ O=build defconfig all
        if timeout 30s $CBL_GIT/boot-utils/boot-uml.sh -k build
            set ret 0
        else
            set ret 1
        end
    end
    git rh HEAD^
else
    git rh
end

if set -q ret
    return $ret
else
    return 125
end
