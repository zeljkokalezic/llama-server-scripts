#!/bin/bash
# Non-MTP Q4_K_M with graph split
SERVER=~/Desktop/ik_llama.cpp/build/bin/llama-server
MODEL=/home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/Qwen3.6-27B-Q4_K_M.gguf
MMPROJ=/home/zeljko/.lmstudio/models/lmstudio-community/Qwen3.6-27B-GGUF/mmproj-Qwen3.6-27B-BF16.gguf
LOG=/tmp/graph-split-test.log
RESULTS=~/Desktop/graph-split-results.txt

run_config() {
    local split=$1
    echo "=== tensor-split=$split ===" | tee -a "$RESULTS"
    
    lsof -ti :8080 2>/dev/null | xargs kill 2>/dev/null
    sleep 3
    
    CUDA_SCALE_LAUNCH_QUEUES=4x \
    $SERVER \
      -m $MODEL \
      --mmproj $MMPROJ \
      --no-mmproj-offload \
      --host 0.0.0.0 --port 8080 \
      --split-mode graph \
      --tensor-split $split \
      --cache-type-k q8_0 --cache-type-v q8_0 \
      --ctx-size 200000 \
      --flash-attn on \
      --jinja --parallel-tool-calls \
      --temp 0.6 --top-p 0.95 --top-k 20 \
      -ngl 999 \
      --chat-template-kwargs '{"preserve_thinking": true}' \
      > "$LOG" 2>&1 &
    local pid=$!
    
    local ready=false
    for i in $(seq 1 90); do
        if curl -s http://127.0.0.1:8080/health 2>/dev/null | grep -q '"status"'; then
            ready=true
            break
        fi
        if ! kill -0 $pid 2>/dev/null; then
            break
        fi
        sleep 2
    done
    
    if [ "$ready" = true ]; then
        echo "  OK" | tee -a "$RESULTS"
        sleep 5
        nvidia-smi --query-gpu=index,memory.used --format=csv,noheader | while read line; do
            echo "  $line" | tee -a "$RESULTS"
        done
    else
        echo "  FAILED" | tee -a "$RESULTS"
        grep "delta-net\|single GPU" "$LOG" | head -2 | sed 's/^/  /' >> "$RESULTS"
    fi
    
    kill $pid 2>/dev/null
    wait $pid 2>/dev/null
    sleep 3
    echo "" >> "$RESULTS"
}

> "$RESULTS"
echo "=== Qwen3.6-27B Q4_K_M (non-MTP) graph split ===" >> "$RESULTS"
echo "Date: $(date)" >> "$RESULTS"
echo "" >> "$RESULTS"

# Known working from MTP: 5,2. Try finer steps.
for s in "3,2" "4,2" "5,2" "5,3" "6,3" "7,3" "7,4" "8,4" "9,4" "9,5" "10,5" "12,5" "15,5" "20,5"; do
    run_config "$s"
done

echo "=== Done ===" >> "$RESULTS"
cat "$RESULTS"
