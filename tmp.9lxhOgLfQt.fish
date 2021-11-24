#!/usr/bin/env fish

set fish_trace 1

rm -rf build

cmake \
    -B build/stage1 \
    -G Ninja \
    -S llvm \
    -Wno-dev \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DCLANG_PLUGIN_SUPPORT=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCOMPILER_RT_BUILD_CRT=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_ENABLE_BACKTRACES=OFF \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_PROJECTS="clang;compiler-rt;lld" \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR= \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_TARGETS_TO_BUILD=host \
    -DLLVM_USE_LINKER=lld &&
    ninja -C build/stage1

cmake \
    -B build/stage2 \
    -G Ninja \
    -S llvm \
    -Wno-dev \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DCLANG_TABLEGEN=$PWD/build/stage1/bin/clang-tblgen \
    -DCLANG_PLUGIN_SUPPORT=OFF \
    -DCMAKE_AR=$PWD/build/stage1/bin/llvm-ar \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$PWD/build/stage1/bin/clang \
    -DCMAKE_CXX_COMPILER=$PWD/build/stage1/bin/clang++ \
    -DCMAKE_RANLIB=$PWD/build/stage1/bin/llvm-ranlib \
    -DLLVM_BUILD_INSTRUMENTED=IR \
    -DLLVM_BUILD_RUNTIME=OFF \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_BACKTRACES=OFF \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_PLUGINS=ON \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR= \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DLLVM_USE_LINKER=$PWD/build/stage1/bin/ld.lld &&
    ninja -C build/stage2 all check-llvm{,-unit}

cmake \
    -B build/training \
    -G Ninja \
    -S llvm \
    -Wno-dev \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DCLANG_TABLEGEN=$PWD/build/stage1/bin/clang-tblgen \
    -DCLANG_PLUGIN_SUPPORT=OFF \
    -DCMAKE_AR=$PWD/build/stage2/bin/llvm-ar \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$PWD/build/stage2/bin/clang \
    -DCMAKE_CXX_COMPILER=$PWD/build/stage2/bin/clang++ \
    -DCMAKE_RANLIB=$PWD/build/stage2/bin/llvm-ranlib \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_BACKTRACES=OFF \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_PLUGINS=ON \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR= \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DLLVM_USE_LINKER=$PWD/build/stage2/bin/ld.lld &&
    ninja -C build/training

mkdir build/stage3

build/stage1/bin/llvm-profdata merge -output=build/stage3/profdata.prof build/stage2/profiles/*.profraw

cmake \
    -B build/stage3 \
    -G Ninja \
    -S llvm \
    -Wno-dev \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DCLANG_TABLEGEN=$PWD/build/stage1/bin/clang-tblgen \
    -DCLANG_PLUGIN_SUPPORT=OFF \
    -DCMAKE_AR=$PWD/build/stage1/bin/llvm-ar \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$PWD/build/stage1/bin/clang \
    -DCMAKE_CXX_COMPILER=$PWD/build/stage1/bin/clang++ \
    -DCMAKE_RANLIB=$PWD/build/stage1/bin/llvm-ranlib \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_BACKTRACES=OFF \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_PLUGINS=ON \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR= \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_PROFDATA_FILE=$PWD/build/stage3/profdata.prof \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DLLVM_USE_LINKER=$PWD/build/stage1/bin/ld.lld &&
    ninja -C build/stage3 check-llvm
