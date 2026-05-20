#!/bin/bash
cd ~/Desktop/llama-benchy && source .venv/bin/activate && llama-benchy \
  --base-url http://127.0.0.1:8080/v1 \
  --model Qwen3.6-27B-Q4_K_M.gguf \
  --pp 2048 \
  --tg 128 \
  --depth 0 4096 8192 16384 32768 \
  --runs 3 \
  --latency-mode generation
