#!/usr/bin/env fish

__in_tree kernel
or return 128

set lnx_bld (tbf)-testing

remkdir $lnx_bld

if not test -e kernel/configs/repro.config
    echo '# CONFIG_DEBUG_INFO_NONE is not set
CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y
CONFIG_MODULE_SIG_FORMAT=y
CONFIG_MODULE_DEBUGFS=y
# CONFIG_MODULE_DEBUG is not set
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODULE_UNLOAD_TAINT_TRACKING=y
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
CONFIG_MODULE_SIG_ALL=y
# CONFIG_MODULE_SIG_SHA1 is not set
# CONFIG_MODULE_SIG_SHA256 is not set
# CONFIG_MODULE_SIG_SHA384 is not set
CONFIG_MODULE_SIG_SHA512=y
# CONFIG_MODULE_SIG_SHA3_256 is not set
# CONFIG_MODULE_SIG_SHA3_384 is not set
# CONFIG_MODULE_SIG_SHA3_512 is not set
CONFIG_MODULE_SIG_HASH="sha512"
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_MODULE_ALLOW_MISSING_NAMESPACE_IMPORTS is not set
CONFIG_MODULE_SIG_KEY="certs/signing_key.pem"
CONFIG_MODULE_SIG_KEY_TYPE_RSA=y
# CONFIG_MODULE_SIG_KEY_TYPE_ECDSA is not set
# CONFIG_WERROR is not set' >kernel/configs/repro.config
end

kmake \
    ARCH=x86_64 \
    # (korg_gcc var x86_64) \
    (korg_llvm var) \
    RPMOPTS="--without devel --define '_tmppath /tmp'" \
    O=$lnx_bld \
    {def,repro.}config binrpm-pkg
or return 125

if not set rpm $lnx_bld/rpmbuild/RPMS/x86_64/*.rpm
    __print_error "No RPM found but build succeeded??"
    return 128
end

set rpmout $lnx_bld/rpmout
rpm2cpio $rpm | cpio -id -D $rpmout
or return 128

if not set mod $rpmout/lib/modules/*/kernel/fs/efivarfs/efivarfs.ko
    __print_error "No efivarfs.ko found??"
    return 128
end

modinfo $mod &| string match -er '^sig[\w|_]+:'
switch "$pipestatus"
    case '0 1'
        echo not signed
        return 1
    case '0 0'
        return 0
    case '*'
        echo modinfo errored??
        return 128
end
