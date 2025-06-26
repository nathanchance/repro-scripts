#!/usr/bin/env fish

if test (count $argv) != 2
    print_error (status basename)' <config> <objtool warning>'
    return 128
end

set config $argv[1]
switch $config
    case fedora
    case '*'
        print_error "Unsupported configuration value: '$config'"
        return 128
end

set full_warning $argv[2]
if not set obj_target (string split -f 1 ': warning: objtool: ' $full_warning)
    print_error "Did not find objtool part to split on in '$full_warning'?"
    return 128
end

in_tree llvm
or return 128

set llvm_bld (tbf)-testing

cbl_bld_llvm_fast \
    --build-folder $llvm_bld \
    --targets X86 (get_host_llvm_target)
or return 125

set lnx_src $CBL_SRC_C/linux
set lnx_bld (tbf $lnx_src)-testing

set kmake_args \
    -C $lnx_src \
    ARCH=x86_64 \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld

switch $config
    case fedora
        prep_config $CBL_LKT/configs/$config/x86_64.config $lnx_bld

        kmake $kmake_args olddefconfig $obj_target &| tee /tmp/build.log
        or return 125
end

if grep -F $full_warning /tmp/build.log
    return 1
end
