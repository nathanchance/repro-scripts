#!/usr/bin/env fish

in_tree kernel
or return 128

set lnx_bld (tbf)-testing
set kmake \
    kmake \
    ARCH=x86_64 \
    (korg_llvm var 19) \
    O=$lnx_bld
set scripts_config \
    scripts/config \
    --file $lnx_bld/.config \
    -d WERROR \
    -e AMD_MEM_ENCRYPT \
    -e FORTIFY_SOURCE
set kboot \
    kboot \
    -a x86_64 \
    -k $lnx_bld \
    -t 30s

begin
    git ap /tmp/mc-dc-no-conficts.diff

    and if git merge-base --is-ancestor c7c18c94a6becc42c71a17fdc6a551aa8efb2999 HEAD
        echo 'diff --git a/arch/x86/crypto/Makefile b/arch/x86/crypto/Makefile
index aa289a9e0153..433358a3835c 100644
--- a/arch/x86/crypto/Makefile
+++ b/arch/x86/crypto/Makefile
@@ -88,5 +88,6 @@ aria-aesni-avx2-x86_64-y := aria-aesni-avx2-asm_64.o aria_aesni_avx2_glue.o
 obj-$(CONFIG_CRYPTO_ARIA_GFNI_AVX512_X86_64) += aria-gfni-avx512-x86_64.o
 aria-gfni-avx512-x86_64-y := aria-gfni-avx512-asm_64.o aria_gfni_avx512_glue.o
 
-# Disable GCOV in odd or sensitive code
+# Disable GCOV and llvm-cov in odd or sensitive code
 GCOV_PROFILE_curve25519-x86_64.o := n
+LLVM_COV_PROFILE_curve25519-x86_64.o := n
'
    else
        echo 'diff --git a/arch/x86/crypto/Makefile b/arch/x86/crypto/Makefile
index 5d19f41bde58..0f65cb575edb 100644
--- a/arch/x86/crypto/Makefile
+++ b/arch/x86/crypto/Makefile
@@ -109,5 +109,6 @@ quiet_cmd_perlasm = PERLASM $@
 $(obj)/%.S: $(src)/%.pl FORCE
 	$(call if_changed,perlasm)
 
-# Disable GCOV in odd or sensitive code
+# Disable GCOV and llvm-cov in odd or sensitive code
 GCOV_PROFILE_curve25519-x86_64.o := n
+LLVM_COV_PROFILE_curve25519-x86_64.o := n
'
    end | git ap
end
or return 128

exit

begin
    # First, make sure the build and boot works without LLVM COV
    $kmake mrproper defconfig
    and $scripts_config
    and $kmake olddefconfig bzImage
    and $kboot

    and $kmake mrproper defconfig
    and $scripts_config -e LLVM_COV_KERNEL -e LLVM_COV_PROFILE_ALL
    # and $kmake olddefconfig bzImage
    and $kmake olddefconfig
end
# or set ret 125
or begin
    git rh
    return 125
end

$kmake bzImage &| tee /tmp/build.log
set build_ret $pipestatus[1]

string match -r "Absolute reference to symbol '__llvm_prf_cnts' not permitted in \.head\.text" </tmp/build.log
set msg_ret $status

git rh
switch "$build_ret:$msg_ret"
    case 0:1
        echo 'Build succeeded but returning fail for git bisect...'
        return 1
    case 1:0
        echo 'Build failed but returning success for git bisect...'
        return 0
end
return 125

git rh
if set -q ret
    return $ret
end

$kboot
switch $status
    case 0
        echo kernel booted successfully but returning fail for git bisect...
        return 1
    case 124
        echo kernel failed to boot but returning success for git bisect...
        return 0
end
return 125
