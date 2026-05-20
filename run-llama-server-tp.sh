#!/bin/bash
# Run llama.cpp server with tensor parallelism (no NCCL, no spec decode)
# Usage: bash ~/Desktop/run-llama-server-tp.sh

NCCL_MIN_NCHANNELS=1 NCCL_P2P_DISABLE=1 NCCL_IGNORE_DISABLED_P2P=1 \
CUDA_SCALE_LAUNCH_QUEUES=4x \
  ~/Desktop/llama.cpp/build/bin/llama-server \
    -m /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/Qwen3.6-27B-Q4_K_M.gguf \
    --mmproj /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/mmproj-Qwen3.6-27B-BF16.gguf \
    --no-mmproj-offload \
    --flash-attn on \
    --split-mode tensor \
    --cache-type-k f16 --cache-type-v f16 \
    --ctx-size 200000 \
    --gpu-layers 99 \
    --tensor-split 3,1 \
    --temp 0.6 --top-p 0.95 --top-k 20 \
    --chat-template-kwargs '{"preserve_thinking": true}'
