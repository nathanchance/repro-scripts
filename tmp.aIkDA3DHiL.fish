#!/usr/bin/env fish

set lnx $CBL_SRC/linux
set cfg $lnx/.config

crl -o $cfg https://github.com/microsoft/WSL2-Linux-Kernel/raw/linux-msft-wsl-5.10.y/Microsoft/config-wsl
kmake -C $lnx clean olddefconfig arch/x86/kernel/setup.o
