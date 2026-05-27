#!/bin/bash
# ik_llama.cpp: Qwen3.6-27B-MTP with graph split + Q8_0 KV + MTP spec decode + mmproj + unified memory
# Usage: bash ~/Desktop/run-ik-mtp.sh

#export GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
#export GGML_CUDA_DISABLE_GRAPHS=1
#export GGML_CUDA_DISABLE_VMM=1

#export CUDA_VISIBLE_DEVICES=1,0

~/Desktop/ik_llama.cpp/build/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/unsloth/Qwen3.6-27B-MTP-GGUF/Qwen3.6-27B-UD-Q5_K_XL.gguf \
  --mmproj /home/zeljko/.lmstudio/models/unsloth/Qwen3.6-27B-MTP-GGUF/mmproj-F32.gguf \
  --host 0.0.0.0 --port 8080 \
  --split-mode graph --tensor-split 5,2 --main-gpu 0 \
  --cache-type-k q8_0 --k-cache-hadamard --cache-type-v q6_0 --cache-type-v-last q8_0,8 --v-cache-hadamard \
  --ctx-size 200000 \
  --flash-attn on --merge-qkv --merge-up-gate-experts \
  --jinja --parallel-tool-calls \
  --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 0.0 --repeat-penalty 1.0 \
  -ngl 999 \
  -mtp --draft-max 14 --spec-autotune -mtprot iq4_ks \
  -smf16 \
  -grt f16 \
  -sas \
  -np 1 \
  --reasoning on  --reasoning-budget 8192 \
  --cache-ram-n-min 20480 --cache-ram-reuse-n-min 20480 \
  --cache-ram 16384  \
  --ctx-checkpoints 64 \
  --ctx-checkpoints-interval 8192 \
  --ctx-checkpoints-tolerance 4096 \
  -t 24 -tb 24 \
  -b 1024 -ub 1024
  
  # --chat-template-kwargs '{"preserve_thinking":true}' --reasoning-budget 8192 --cache-ram-keep-on-load


