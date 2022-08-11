#!/usr/bin/env fish

set gcc_src $SRC_FOLDER/gcc
set gcc_bld $TMP_BUILD_FOLDER/gcc

begin
    rm -fr $gcc_bld
    and mkdir $gcc_bld
    and cd $gcc_bld
    and $gcc_src/configure \
        --target=x86_64-linux \
        --enable-targets=all \
        --enable-languages=c \
        --without-headers \
        --disable-bootstrap \
        --disable-nls \
        --disable-threads \
        --disable-shared \
        --disable-libmudflap \
        --disable-libssp \
        --disable-libgomp \
        --disable-decimal-float \
        --disable-libquadmath \
        --disable-libatomic \
        --disable-libcc1 \
        --disable-libmpx \
        --disable-multilib \
        --enable-checking=release
    and make -j(nproc)
end; or return 125

echo 'extern void foo(int *);

void bar(int a)
{
    switch (a) {
    case 1:
        int b;
        foo(&b);
        break;
    case 2:
        ;
    default:
        ;
    }
}' | $gcc_bld/gcc/xgcc -B $gcc_bld/gcc -fsyntax-only -x c -
switch "$pipestatus"
    case "0 0"
        return 1
    case "0 1"
        return 0
    case '*'
        return 125
end
