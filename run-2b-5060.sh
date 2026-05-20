#!/bin/bash
# ik_llama.cpp: Qwen3.5-2B on RTX 5060 Ti (GPU 1)
# Usage: bash ~/Desktop/run-2b-5060.sh

CUDA_VISIBLE_DEVICES=1 ~/Desktop/ik_llama.cpp/build/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.5-2B-GGUF/Qwen3.5-2B-Q4_K_M.gguf \
  --host 0.0.0.0 --port 8081 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --ctx-size 262144 \
  --flash-attn on \
  --jinja --parallel-tool-calls \
  --temp 0.6 --top-p 0.95 --top-k 20 \
  -b 1280 -ub 1280 \
  -ngl 999 \
  --no-mmap \
  --slot-save-path /tmp/llama-slots \
  --ctx-checkpoints 8 --ctx-checkpoints-tolerance 5
