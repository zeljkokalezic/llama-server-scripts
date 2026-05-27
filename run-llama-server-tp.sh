#!/bin/bash
# Run llama.cpp server with tensor parallelism (no NCCL, no spec decode)
# Usage: bash ~/Desktop/run-llama-server-tp.sh

GGML_CUDA_P2P=1 \
  ~/Desktop/llama.cpp/build/bin/llama-server \
    -m /home/zeljko/.lmstudio/models/unsloth/Qwen3.6-27B-MTP-GGUF/Qwen3.6-27B-UD-Q5_K_XL.gguf \
    --mmproj /home/zeljko/.lmstudio/models/unsloth/Qwen3.6-27B-MTP-GGUF/mmproj-F32.gguf \
    --no-mmproj-offload \
    --flash-attn on \
    --split-mode tensor \
    --cache-type-k f16 --cache-type-v f16 \
    --ctx-size 10000 \
    --gpu-layers 99 \
    --tensor-split 3,1 \
    --temp 0.6 --top-p 0.95 --top-k 20 \
    --spec-type draft-mtp \
    --spec-draft-n-max 15

