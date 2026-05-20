#!/bin/bash
# ik_llama.cpp: Qwen3.6-27B-MTP with graph split + Q8_0 KV + MTP spec decode + -np 2
# Quiet variant: drops -v / --log-enable so VERB-level traces are suppressed.
# Errors, warnings, and the per-request timing summaries still print.
# Usage: bash ~/Desktop/run-ik-mtp-np2-quiet.sh

~/Desktop/ik_llama.cpp/build/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/unsloth/Qwen3.6-27B-MTP-GGUF/Qwen3.6-27B-UD-Q5_K_XL.gguf \
  --host 0.0.0.0 --port 8080 \
  --split-mode graph --tensor-split 5,2 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --ctx-size 128000 \
  --flash-attn on \
  --jinja --parallel-tool-calls \
  --temp 0.6 --top-p 0.95 --top-k 20 \
  -ngl 999 \
  -mtp --draft-max 15 \
  --no-mmap \
  -np 2
