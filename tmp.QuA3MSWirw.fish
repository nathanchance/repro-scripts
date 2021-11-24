#!/usr/bin/env fish

set lnx $CBL_SRC/linux-stable-5.14

git -C $lnx cl -q

crl -o $lnx/.config https://github.com/ClangBuiltLinux/linux/files/7197432/config.txt

$lnx/scripts/config --file $lnx/.config -d TEST_BPF

set -e fish_trace

NO_CCACHE=true PO=$TMP_FOLDER/llvm-85b4b21c8bbad346d58a30154d2767c39cf3285a/bin kmake -C $lnx LLVM=1 LLVM_IAS=1 KCFLAGS="-march=native -mtune=native -mllvm -polly -mllvm -polly-parallel -mllvm -polly-vectorizer=stripmine -mllvm -polly-omp-backend=LLVM -mllvm -polly-num-threads=24 -mllvm -polly-scheduling=dynamic -mllvm -polly-scheduling-chunksize=1 -mllvm -polly-ast-use-context -mllvm -polly-invariant-load-hoisting -mllvm -polly-opt-fusion=max -mllvm -polly-run-inliner -mllvm -polly-run-dce -fno-math-errno -fno-trapping-math -falign-functions=32 -fno-semantic-interposition" V=1 olddefconfig drivers/gpu/drm/amd/amdgpu/../amdkfd/kfd_mqd_manager.{i,o}
