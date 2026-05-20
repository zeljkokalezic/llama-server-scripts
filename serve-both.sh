#!/bin/bash
# Start both llama.cpp model servers
# Qwen3.6-27B on port 8080 (both GPUs, tensor-split)
# Qwen3.5-2B on port 8081 (RTX 5060 Ti only)

SERVER=~/Desktop/ik_llama.cpp/build/bin/llama-server
MODEL_DIR=/home/zeljko/.lmstudio/models
MODEL_27B=$MODEL_DIR/lmstudio-community/Qwen3.6-27B-GGUF/Qwen3.6-27B-Q4_K_M.gguf
MMPROJ_27B=$MODEL_DIR/lmstudio-community/Qwen3.6-27B-GGUF/mmproj-Qwen3.6-27B-BF16.gguf
MODEL_2B=$MODEL_DIR/lmstudio-community/Qwen3.5-2B-GGUF/Qwen3.5-2B-Q4_K_M.gguf
MMPROJ_2B=$MODEL_DIR/lmstudio-community/Qwen3.5-2B-GGUF/mmproj-Qwen3.5-2B-BF16.gguf

cleanup() {
    echo "Shutting down servers..."
    kill $PID_27B $PID_2B 2>/dev/null
    # Kill any orphaned server processes on our ports
    for port in 8080 8081; do
        lsof -ti :$port 2>/dev/null | xargs kill 2>/dev/null || true
    done
    wait
}

trap cleanup EXIT INT TERM

# Start 27B on port 8080 with auto-restart
(
  while true; do
    CUDA_SCALE_LAUNCH_QUEUES=4x \
      $SERVER \
        -m $MODEL_27B \
        --mmproj $MMPROJ_27B \
        --no-mmproj-offload \
        --flash-attn on \
        --split-mode graph \
        --tensor-split 5,2 \
        --cache-type-k q8_0 --cache-type-v q8_0 \
        --ctx-size 200000 \
        --gpu-layers 99 \
        -b 1280 -ub 1280 \
        --parallel 1 \
        --temp 0.6 --top-p 0.95 --top-k 20 \
        --port 8080 \
        --no-mmap \
        --slot-save-path /tmp/llama-slots \
        --ctx-checkpoints 8 --ctx-checkpoints-tolerance 5 \
        --chat-template-kwargs '{"preserve_thinking": true}'
    echo "[27B] crashed with code $? — restarting in 2s"
    sleep 2
  done
) &
PID_27B=$!

# Start 2B on port 8081 (5060 Ti only) with auto-restart
(
  while true; do
    $SERVER \
        -m $MODEL_2B \
        --mmproj $MMPROJ_2B \
        --no-mmproj-offload \
        --flash-attn on \
        --split-mode graph \
        --main-gpu 1 \
        --cache-type-k q8_0 --cache-type-v q8_0 \
        --ctx-size 262144 \
        --gpu-layers 99 \
        -b 1280 -ub 1280 \
        --parallel 1 \
        --no-cache-idle-slots \
        --temp 0.6 --top-p 0.95 --top-k 20 \
        --port 8081 \
        --no-mmap \
        --slot-save-path /tmp/llama-slots \
        --ctx-checkpoints 8 --ctx-checkpoints-tolerance 5 \
        --chat-template-kwargs '{"preserve_thinking": true}'
    echo "[2B] crashed with code $? — restarting in 2s"
    sleep 2
  done
) &
PID_2B=$!

echo "Qwen3.6-27B starting on http://127.0.0.1:8080 (PID $PID_27B)"
echo "Qwen3.5-2B  starting on http://127.0.0.1:8081 (PID $PID_2B)"
echo "Waiting for servers... Ctrl+C to stop both"

wait
