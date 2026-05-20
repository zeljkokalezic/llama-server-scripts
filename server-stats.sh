#!/bin/bash
# Real-time llama-server monitor (tps + GPU stats)
# Run: bash ~/Desktop/server-stats.sh
# Ctrl+C to stop

INTERVAL=10

measure_tps() {
    local PORT=$1
    local LABEL=$2
    
    # Quick completion benchmark: generate 64 tokens, measure time
    local START=$(date +%s%N)
    local RESP=$(curl -s -X POST "http://127.0.0.1:${PORT}/v1/completions" \
        -H "Content-Type: application/json" \
        -d '{"model":"default","prompt":".","max_tokens":64,"temperature":0,"stream":false}' 2>/dev/null)
    local END=$(date +%s%N)
    
    if [ $? -ne 0 ]; then
        echo "OFFLINE"
        return
    fi
    
    local TOKENS=$(echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('usage',{}).get('completion_tokens',0))" 2>/dev/null)
    local DURATION=$(( (END - START) / 1000000 ))  # ms
    
    if [ "$DURATION" -gt 0 ] && [ "${TOKENS:-0}" -gt 0 ]; then
        local TPS=$(echo "scale=1; $TOKENS * 1000 / $DURATION" | bc 2>/dev/null)
        echo "${TPS} t/s (${TOKENS} tokens in ${DURATION}ms)"
    else
        echo "error"
    fi
}

clear

while true; do
    clear
    echo "=== Server Stats ($(date '+%H:%M:%S %Z')) ==="
    echo ""
    
    # Measure tps for each server
    TPS_8080=$(measure_tps 8080 "Qwen3.6-27B")
    TPS_8081=$(measure_tps 8081 "Qwen3.5-2B")
    
    printf "%-16s %s\n" "Qwen3.6-27B (8080)" "$TPS_8080"
    printf "%-16s %s\n" "Qwen3.5-2B (8081)"  "$TPS_8081"
    echo ""
    
    # GPU stats
    printf "%-14s %-8s %-8s %-8s %-8s\n" "GPU" "Clock" "Temp" "Power" "Memory"
    echo "----------------------------------------------------"
    nvidia-smi --query-gpu=name,clocks.current.sm,temperature.gpu,power.draw,memory.used --format=csv,noheader,nounits 2>/dev/null | \
        while IFS=',' read -r NAME CLK TEMP PWR MEM; do
            printf "%-14s %-8s %-8s %-8s %s MB\n" "$NAME" "${CLK}MHz" "${TEMP}C" "${PWR}W" "$MEM"
        done
    
    echo ""
    echo "Next refresh in ${INTERVAL}s | Ctrl+C to stop"
    
    sleep "$INTERVAL"
done
