#!/usr/bin/env fish

set lnx $CBL_SRC/linux-next

kmake -C $lnx distclean defconfig bzImage; or exit 125

podman run \
    --interactive \
    --rm \
    --tty \
    --volume=$CBL_GIT/boot-utils:/boot-utils \
    --volume=$lnx:$lnx \
    --workdir=$lnx \
    docker.io/debian \
    bash -c 'apt update &>/dev/null &&
apt upgrade -y &>/dev/null &&
apt install -y --no-install-recommends qemu-system-x86 expect zstd &>/dev/null &&
/boot-utils/boot-qemu.sh -a x86_64 -k . -t 30s'

set exit $status
if test $exit -eq 124
    exit 1
else if test $exit -eq 0
    exit 0
else
    exit 125
end
