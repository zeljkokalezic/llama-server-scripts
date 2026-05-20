#!/bin/bash
# ik_llama.cpp: Qwen3.5-2B
# Usage: bash ~/Desktop/run-ik-2b.sh

export GGML_CUDA_ENABLE_UNIFIED_MEMORY=1

~/Desktop/ik_llama.cpp/build/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.5-2B-GGUF/Qwen3.5-2B-Q4_K_M.gguf \
  --host 0.0.0.0 --port 8081 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --ctx-size 200000 \
  --flash-attn on \
  --jinja --parallel-tool-calls \
  --temp 0.6 --top-p 0.95 --top-k 20 \
  --device CUDA0 \
  -ngl 999 \
  --no-mmap