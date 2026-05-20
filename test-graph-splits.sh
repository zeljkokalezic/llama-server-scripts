#!/bin/bash
# Find maximum 27B fit on 3090 with --split-mode graph + different tensor-splits
# Uses ik_llama.cpp fork, 200K context, Q4_K_M model

SERVER=~/Desktop/ik_llama.cpp/build/bin/llama-server
MODEL=/home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/Qwen3.6-27B-Q4_K_M.gguf
MMPROJ=/home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/mmproj-Qwen3.6-27B-BF16.gguf

RESULTS_FILE=~/Desktop/graph-split-results.txt
> "$RESULTS_FILE"

cleanup() {
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
}
trap cleanup EXIT INT TERM

run_test() {
    local split=$1
    echo "=== Testing --tensor-split $split (split-mode graph) ===" | tee -a "$RESULTS_FILE"
    
    # Kill previous server
    lsof -ti :8080 2>/dev/null | xargs kill 2>/dev/null
    sleep 2
    
    # Start server
    CUDA_SCALE_LAUNCH_QUEUES=4x \
    $SERVER \
      -m $MODEL \
      --mmproj $MMPROJ \
      --no-mmproj-offload \
      --flash-attn on \
      --split-mode graph \
      --tensor-split $split \
      --cache-type-k f16 --cache-type-v f16 \
      --ctx-size 200000 \
      --gpu-layers 99 \
      --port 8080 \
      --temp 0.6 --top-p 0.95 --top-k 20 \
      --chat-template-kwargs '{"preserve_thinking": true}' \
      2>&1 | head -500 &
    SERVER_PID=$!
    
    # Wait for server to start or crash
    local max_wait=120
    local started=false
    for i in $(seq 1 $max_wait); do
        if curl -s http://127.0.0.1:8080/health 2>/dev/null | grep -q "ok"; then
            started=true
            break
        fi
        # Check if server died
        if ! kill -0 $SERVER_PID 2>/dev/null; then
            break
        fi
        sleep 1
    done
    
    if [ "$started" = true ]; then
        echo "  Server started successfully" | tee -a "$RESULTS_FILE"
        
        # Wait for model load to finish, check VRAM
        sleep 10
        
        # Get GPU memory usage
        echo "  VRAM usage:" | tee -a "$RESULTS_FILE"
        nvidia-smi --query-gpu=index,name,memory.used,memory.total --format=csv,noheader | while read line; do
            echo "    GPU: $line" | tee -a "$RESULTS_FILE"
        done
        
        # Send a short prompt and measure throughput
        echo "  Throughput test:" | tee -a "$RESULTS_FILE"
        local result=$(curl -s http://127.0.0.1:8080/v1/completions \
          -H "Content-Type: application/json" \
          -d '{
            "prompt": "Write a short sentence:",
            "max_tokens": 50,
            "temperature": 0.0,
            "stream": false
          }' 2>&1)
        
        if echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"    Generated {len(d.get('choices',[{}])[0].get('text','').split())} words\")" 2>/dev/null; then
            true
        else
            echo "    $result" | head -5 | tee -a "$RESULTS_FILE"
        fi
        
        # Get timings from server logs if available
        sleep 2
        
        kill $SERVER_PID 2>/dev/null
        wait $SERVER_PID 2>/dev/null
    else
        echo "  FAILED to start (timeout or crash)" | tee -a "$RESULTS_FILE"
        wait $SERVER_PID 2>/dev/null
    fi
    echo "" | tee -a "$RESULTS_FILE"
    sleep 3
}

echo "=== Graph Split Mode Experiment — Qwen3.6-27B Q4_K_M, ctx 200K ===" | tee -a "$RESULTS_FILE"
echo "Date: $(date)" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# Test configurations: increasing GPU0 (3090) share
# Format: gpu0,gpu1 — higher first number = more on 3090
SPLITS=(
  "1,0"        # 100% on 3090
  "3,0"        # 3090 only (normalized)
  "99,0"       # 3090 only (max bias)
  "1,1"        # equal split
  "3,1"        # 75% 3090, 25% 5060Ti (baseline tensor mode used this)
  "4,1"        # 80% on 3090
  "5,1"        # 83% on 3090
  "5,2"        # 71% 3090, 29% 5060Ti (ik fork default for MTP)
  "7,1"        # 87% on 3090
)

for split in "${SPLITS[@]}"; do
    run_test "$split"
done

echo "=== Complete ===" | tee -a "$RESULTS_FILE"
echo "Results saved to $RESULTS_FILE"
