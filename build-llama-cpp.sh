#!/bin/bash
# Build llama.cpp with CUDA 13.2 for RTX 3090 (CC 8.6) + RTX 5060 Ti (CC 12.0)
# Usage: bash ~/Desktop/build-llama-cpp.sh

cmake -S /home/zeljko/Desktop/llama.cpp -B /home/zeljko/Desktop/llama.cpp/build \
  -DGGML_CUDA=ON \
  -DGGML_CUDA_NCCL=ON \
  -DCMAKE_CUDA_COMPILER=/usr/local/cuda-13.2/bin/nvcc \
  -DCUDAToolkit_ROOT=/usr/local/cuda-13.2 \
  -DCUDA_CUDART=/usr/local/cuda-13.2/lib64/libcudart.so \
  -DCUDA_cudart_LIBRARY=/usr/local/cuda-13.2/lib64/libcudart.so \
  -DCMAKE_CUDA_ARCHITECTURES="86;120" \
  -DGGML_CUDA_FA=ON \
  -DGGML_CUDA_GRAPHS=ON \
  -DGGML_CUDA_COMPRESSION_MODE=size \
  -DCMAKE_BUILD_TYPE=Release \
  -G "Unix Makefiles" && \
cmake --build /home/zeljko/Desktop/llama.cpp/build -j $(nproc)
