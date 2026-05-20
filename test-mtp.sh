#!/bin/bash
# MTP speculative decoding benchmark for Qwen3.6-27B-MTP
# Tests: baseline vs MTP with varying draft-max values
# Outputs: comparison table with tokens/sec, acceptance rate, latency

set -euo pipefail

MODEL="/home/zeljko/.lmstudio/models/unsloth/Qwen3.6-27B-MTP-GGUF/Qwen3.6-27B-UD-Q5_K_XL.gguf"
BIN="/home/zeljko/Desktop/llama.cpp/build/bin/llama-cli"
PROMPT="Write a detailed explanation of how transformer attention mechanisms work, including mathematical formulations and computational complexity analysis."
N_PREDICT=128
TMPDIR="/tmp/mtp-bench-$$"
mkdir -p "$TMPDIR"

# GPU setup: 3090 only (graph-split MTP has P2P bug with 5060 Ti)
GPU_FLAGS="-ngl 999 --flash-attn on -smf16 -grt f16 -sas --cache-type-k q8_0 --cache-type-v q8_0 --no-mmap"
THREAD_FLAGS="-t 8 -tb 16"
COMMON_FLAGS="-c 4096 -b 2048 -ub 512 --temp 0.7 --top-p 0.9 --perf --no-warmup --log-disable"

echo "=============================================="
echo " MTP Speculative Decoding Benchmark"
echo " Model: Qwen3.6-27B-UD-Q5_K_XL"
echo " Predict: $N_PREDICT tokens | GPU: RTX 3090 only"
echo "=============================================="
echo ""

# Collect results
RESULTS=""

run_test() {
    local label="$1"
    local spec_flags="$2"
    local output_file="$TMPDIR/${label// /_}.txt"

    echo "--- $label ---"

    "$BIN" \
        -m "$MODEL" \
        $GPU_FLAGS \
        $THREAD_FLAGS \
        $COMMON_FLAGS \
        -p "$PROMPT" \
        -n "$N_PREDICT" \
        $spec_flags \
        2>&1 | tee "$output_file" | tail -15

    # Parse perf timing from output
    local gen_tps gen_ms token_ms prefill_tps prefill_ms
    gen_tps=$(grep -oP 'token eval time=\s*\K[\d.]+' "$output_file" | tail -1 || echo "N/A")
    gen_ms=$(grep -oP 'token eval time=\s*[\d.]+\s*\K[\d.]+' "$output_file" | tail -1 || echo "N/A")
    prefill_tps=$(grep -oP 'prompt eval time=\s*\K[\d.]+' "$output_file" | tail -1 || echo "N/A")
    prefill_ms=$(grep -oP 'prompt eval time=\s*[\d.]+\s*\K[\d.]+' "$output_file" | tail -1 || echo "N/A")

    # Parse speculative stats if present
    local spec_accept="N/A" spec_draft="N/A"
    if grep -q 'speculative' "$output_file" 2>/dev/null; then
        spec_accept=$(grep -oP 'speculative accept rate:\s*\K[\d.]+' "$output_file" | tail -1 || echo "N/A")
        spec_draft=$(grep -oP 'speculative draft tokens:\s*\K[\d.]+' "$output_file" | tail -1 || echo "N/A")
    fi

    echo ""
    RESULTS+="| $label | $gen_tps | $gen_ms | $prefill_tps | $prefill_ms | ${spec_accept}% | $spec_draft |"$'\n'
    echo ""
}

# Test 1: Baseline - no speculative decoding
run_test "Baseline (no spec)" "--spec-type none"

# Test 2: MTP with draft-max 4
run_test "MTP draft=4" "--spec-type draft-mtp --spec-draft-n-max 4"

# Test 3: MTP with draft-max 8
run_test "MTP draft=8" "--spec-type draft-mtp --spec-draft-n-max 8"

# Test 4: MTP with draft-max 12
run_test "MTP draft=12" "--spec-type draft-mtp --spec-draft-n-max 12"

# Test 5: MTP with draft-max 16 (default)
run_test "MTP draft=16" "--spec-type draft-mtp --spec-draft-n-max 16"

# Test 6: MTP with draft-max 20
run_test "MTP draft=20" "--spec-type draft-mtp --spec-draft-n-max 20"

# Test 7: MTP with draft-max 24
run_test "MTP draft=24" "--spec-type draft-mtp --spec-draft-n-max 24"

# Print results table
echo "=============================================="
echo " RESULTS"
echo "=============================================="
echo ""
printf "%-25s | %-12s | %-10s | %-12s | %-10s | %-10s | %-8s\n" \
    "CONFIG" "GEN t/s" "GEN ms/tok" "PREFILL t/s" "PREFILL ms/t" "ACCEPT%" "DRAFT"
printf "%s\n" "$(printf '%.0s-' {1..100})"
echo "$RESULTS" | column -t -s'|'
echo ""

# Cleanup
rm -rf "$TMPDIR"

echo "Done."
