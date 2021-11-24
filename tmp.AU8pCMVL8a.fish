#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project
set tmp_install (mktemp -d -p $TMP_FOLDER)

podcmd -n \
    $CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --check-targets clang ll{d,vm{,-unit}} \
    --install-folder $tmp_install \
    --install-stage1-only \
    --llvm-folder $llvm \
    --projects \"clang\;lld\" \
    --targets \"ARM\;X86\" \
    --show-build-commands
or exit 125

podcmd -n \
    $CBL_GIT/tc-build/build-binutils.py \
    --install-folder $tmp_install \
    --targets arm; or exit 125

cbl_lkt \
    --tc-prefix $tmp_install \
    --tree $CBL_WRKTR/cbl-1502
