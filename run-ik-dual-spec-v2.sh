#!/bin/bash
# ik_llama.cpp: Qwen3.6-27B-MTP with dual speculative decoding
# Composite stages: ngram-mod (self-spec) -> MTP (fallback)
# Usage: bash ~/Desktop/run-ik-dual-spec-v2.sh

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
  --spec-stage ngram-mod:n_max=64,n_min=2,spec-ngram-size-n=16 \
  --spec-stage mtp:n_max=15,draft-p-min=0.5 \
  --no-mmap \
  -np 1
