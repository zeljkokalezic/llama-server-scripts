#!/bin/bash
# CPU-only: Qwen3.5-4B-MTP with Q8_0 KV cache, MTP spec decode, flash attention
# Usage: bash ~/Desktop/run-cpu-qwen35-4b-mtp.sh

~/Desktop/CPU\ ONLY\ ik_llama.cpp/build-cpu/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/unsloth/Qwen3.5-4B-MTP-GGUF/Qwen3.5-4B-UD-Q4_K_XL.gguf \
  --host 0.0.0.0 --port 8081 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --ctx-size 200000 \
  --flash-attn on \
  --jinja --parallel-tool-calls \
  --temp 0.6 --top-p 0.95 --top-k 20 \
  --threads $(nproc) \
  --multi-token-prediction \
  --draft 16 \
  --draft-p-min 0.8 \
  --no-mmap
