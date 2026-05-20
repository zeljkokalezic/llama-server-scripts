#!/bin/bash
~/Desktop/llama.cpp/build/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/Qwen3.6-27B-Q4_K_M.gguf \
  --mmproj /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/mmproj-Qwen3.6-27B-BF16.gguf \
  --no-mmproj-offload \
  --flash-attn on \
  --spec-type ngram-mod \
  --spec-ngram-mod-n-min 12 \
  --spec-ngram-mod-n-max 48 \
  --spec-ngram-mod-n-match 24 \
  --ctx-size 128000 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --gpu-layers 99 \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --chat-template-kwargs '{"preserve_thinking": true}'
