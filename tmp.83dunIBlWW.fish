#!/usr/bin/env fish

__in_tree llvm
or return 128

set llvm_bld (tbf)-testing

#cbl_patch_llvm
#or return 128

cbl_bld_llvm_fast \
    --no-assertions \
    --build-folder $llvm_bld \
    --targets Hexagon (get_host_llvm_target)
or return 125
#or set ret 125
#git rh
#set -q ret
#and return $ret

if false
    set lnx_src $CBL_SRC_C/linux-next
    set lnx_bld (tbf $lnx_src)-testing
    remkdir $lnx_bld

    set lnx_bld_log (mktemp -p $lnx_bld --suffix=.log)

    timeout 3m fish -c "kmake \
    -C $lnx_src \
    ARCH=hexagon \
    KCONFIG_ALLCONFIG=(print_no_werror_cfgs | psub) \
    LLVM=$llvm_bld/final/bin/ \
    O=$lnx_bld \
    mrproper allmodconfig drivers/media/platform/rockchip/rkvdec/rkvdec-vdpu383-h264.o"
else
    timeout 3m $llvm_bld/final/bin/clang \
        --target=hexagon-linux-musl \
        -ffixed-r19 \
        -ftrivial-auto-var-init=pattern \
        -fms-anonymous-structs \
        -O2 \
        -Wno-microsoft-anon-tag \
        -x c \
        -c \
        -o /dev/null \
        $TMP_FOLDER/cvise.pQ1Zcj3isM/cvise/rkvdec-vdpu383-h264.i.orig
end
switch "$status"
    case 0
        return 0
    case 124
        __print_error "Build timed out!"
        return 1
end
__print_error "Build failed unexpected?"
return 125
