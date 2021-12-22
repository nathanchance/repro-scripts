#!/usr/bin/env fish

set llvm $CBL_SRC/llvm-project

$CBL_GIT/tc-build/build-llvm.py \
    --assertions \
    --build-folder $llvm/build \
    --build-stage1-only \
    --defines LLVM_INCLUDE_BENCHMARKS=OFF \
    --llvm-folder $llvm \
    --projects "clang;polly" \
    --targets ARM \
    --show-build-commands; or exit 125

echo 'struct v4l2_sliced_vbi_data {
  unsigned char data[48];
};
struct {
  struct v4l2_sliced_vbi_data data[5];
} vivid_vbi_gen_sliced_vbi;
int calc_parity_i;
void vivid_vbi_gen_teletext(unsigned char *packet) {
  char __trans_tmp_1;
  unsigned i;
  packet[0] = packet[6];
  i = 0;
  for (; i < 42; i++) {
    char val = packet[i];
    unsigned tot = calc_parity_i = 0;
    for (; calc_parity_i < 7; calc_parity_i++)
      tot += val & 1 << calc_parity_i ? 1 : 0;
    __trans_tmp_1 = tot & 1;
    packet[i] = __trans_tmp_1;
  }
}
void vivid_vbi_gen_sliced() {
  struct v4l2_sliced_vbi_data *data0 = vivid_vbi_gen_sliced_vbi.data;
  unsigned i = 0;
  for (; i <= 11; i++) {
    vivid_vbi_gen_teletext(data0->data);
    data0++;
  }
}' | $llvm/build/stage1/bin/clang \
   --target=arm-linux-gnueabi \
   -march=armv7-a \
   -msoft-float \
   -O2 \
   -mllvm -polly \
   -mllvm -polly-vectorizer=stripmine \
   -mllvm -polly-opt-fusion=max \
   -c -x c -o /dev/null - &| \
   grep "cannot insert node between set or sequence node and its filter children"

set pipe_status $pipestatus
if test "$pipe_status[2]" -eq 0
    exit 0
else
    if test "$pipe_status[3]" -eq 0
        exit 1
    else
        exit 125
    end
end
