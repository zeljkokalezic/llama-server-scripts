#!/bin/bash
# ik_llama.cpp: launch both MTP 27B (8080) + 2B (8081)
# Usage: bash ~/Desktop/run-ik-both.sh

set -e

cleanup() {
    echo "Shutting down..."
    kill $PID_2B $PID_MTP 2>/dev/null
    wait $PID_2B $PID_MTP 2>/dev/null
    echo "Done"
}
trap cleanup EXIT INT TERM

echo "Starting 2B on port 8081..."
# bash ~/Desktop/run-ik-2b.sh &
# PID_2B=$!

echo "Starting MTP 27B on port 8080..."
bash ~/Desktop/run-ik-mtp.sh &
PID_MTP=$!

# echo "Waiting for 2B..."
# for i in $(seq 1 30); do
#     if curl -s http://127.0.0.1:8081/health >/dev/null 2>&1; then
#         echo "2B ready (port 8081)"
#         break
#     fi
#     sleep 1
# done

echo "Waiting for MTP 27B..."
for i in $(seq 1 60); do
    if curl -s http://127.0.0.1:8080/health >/dev/null 2>&1; then
        echo "MTP 27B ready (port 8080)"
        break
    fi
    sleep 1
done

echo "MTP 27B running. Press Ctrl+C to stop."
wait || true
