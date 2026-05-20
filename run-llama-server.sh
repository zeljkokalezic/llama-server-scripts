#!/bin/bash
# Run llama.cpp server with Q8 KV cache + ngram spec decoding (layer-split mode)
# Usage: bash ~/Desktop/run-llama-server.sh

CUDA_SCALE_LAUNCH_QUEUES=4x \
  ~/Desktop/llama.cpp/build/bin/llama-server \
    -m /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/Qwen3.6-27B-Q4_K_M.gguf \
    --mmproj /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/mmproj-Qwen3.6-27B-BF16.gguf \
    --no-mmproj-offload \
    --flash-attn on \
    --split-mode layer \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --ctx-size 200000 \
    --gpu-layers 99 \
    --tensor-split 3,1 \
    --spec-type ngram-mod \
    --spec-ngram-mod-n-min 12 \
    --spec-ngram-mod-n-max 48 \
    --spec-ngram-mod-n-match 24 \
    --temp 0.6 --top-p 0.95 --top-k 20 \
    --chat-template-kwargs '{"preserve_thinking": true}'
