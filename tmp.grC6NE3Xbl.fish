#!/usr/bin/env fish

__in_tree kernel
or return 128

if false
    begin
        git diff 60ddf3eed499^..087dd6d2cc12 | git ap
        and git diff dc432ab7130b^..05988dba1179 | git ap --exclude init/main.c
        and echo 'diff --git a/init/main.c b/init/main.c
index 13aeb7834111..453ac9dff2da 100644
--- a/init/main.c
+++ b/init/main.c
@@ -106,6 +106,7 @@
 #include <linux/time_namespace.h>
 #include <linux/unaligned.h>
 #include <linux/percpu_counter_tree.h>
+#include <linux/vdso_datastore.h>
 #include <net/net_namespace.h>
 
 #include <asm/io.h>
@@ -1121,6 +1122,7 @@ void start_kernel(void)
 	srcu_init();
 	hrtimers_init();
 	softirq_init();
+	vdso_setup_data_pages();
 	timekeeping_init();
 	time_init();
 
' | git ap
    end
    or return 128
end

set lnx_bld (tbf)-testing

kmake \
    ARCH=powerpc \
    (korg_gcc var powerpc64) \
    O=$lnx_bld \
    mrproper ppc64_guest_defconfig vmlinux
set krnl_ret $status
if false
    test $krnl_ret -eq 0
    or set ret 125
    git rh
    set -q ret
    and return $ret
else
    test $krnl_ret -eq 0
    or return 125
end

kboot \
    -a ppc64 \
    -k $lnx_bld \
    -t 45s
switch $status
    case 0
        return 0
    case 124
        return 1
end
return 125
