#!/bin/bash
# atomic-llama-cpp-turboquant: Qwen3.6-27B-UDT-MTP + NextN spec decode + turbo3 KV
# Usage: bash ~/Desktop/run-turboquant.sh

CUDA_VISIBLE_DEVICES=0 ~/Desktop/atomic-llama-cpp-turboquant/build/bin/llama-server \
  -m /home/zeljko/.lmstudio/models/AtomicChat/Qwen3.6-27B-UDT-MTP-GGUF/Qwen3.6-27B-UDT-Q4_K_XL_MTP.gguf \
  --host 0.0.0.0 --port 8080 \
  -ctk turbo3 -ctv turbo3 \
  -ctkd f16 -ctvd f16 \
  -c 150000 \
  -fa on --jinja \
  --temp 0.6 --top-p 0.95 --top-k 20 \
  -ngl 999 \
  -md /home/zeljko/.lmstudio/models/AtomicChat/Qwen3.6-27B-UDT-MTP-GGUF/Qwen3.6-27B-UDT-Q4_K_XL_MTP.gguf \
  --spec-type nextn \
  --draft-max 15 \
  --no-mmap -np 1 \
  --cont-batching \
  --slot-save-path /tmp/llama-slots \
  --ctx-checkpoints 8
