#!/bin/bash
# Build CPU-only ik_llama.cpp (no CUDA) with native optimizations
# Usage: bash ~/Desktop/build-cpu-ik-llama-cpp.sh

set -e
cd "/home/zeljko/Desktop/CPU ONLY ik_llama.cpp"
rm -rf build-cpu && mkdir build-cpu
cmake -S . -B build-cpu \
  -DGGML_NATIVE=ON \
  -DGGML_CUDA=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -G "Unix Makefiles" && \
cmake --build build-cpu -j $(nproc)
