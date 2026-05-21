# Local LLM Serving Scripts

Collection of scripts for building and running local LLM servers using `llama.cpp` and forks (`ik_llama.cpp`, `atomic-llama-cpp-turboquant`, `beellama.cpp`).

## Hardware Setup

- **GPU 0**: RTX 3090 (CC 8.6)
- **GPU 1**: RTX 5060 Ti (CC 12.0)

## Build Scripts

| Script | Description |
|--------|-------------|
| `build-cpu-ik-llama-cpp.sh` | Build CPU-only `ik_llama.cpp` (no CUDA) with native optimizations |
| `build-ik-llama-cpp.sh` | Build `ik_llama.cpp` with CUDA 13.2 for both GPUs |
| `build-llama-cpp.sh` | Build upstream `llama.cpp` with CUDA 13.2 for both GPUs |

## Run Scripts — ik_llama.cpp

| Script | Model | Notes |
|--------|-------|-------|
| `run-ik-mtp.sh` | Qwen3.6-27B-MTP | Graph split + Q8_0 KV + MTP spec decode + mmproj + unified memory |
| `run-ik-mtp-np2.sh` | Qwen3.6-27B-MTP | Same as above with `-np 2` |
| `run-ik-mtp-np2-quiet.sh` | Qwen3.6-27B-MTP | `-np 2` variant with verbose logging suppressed |
| `run-ik-mtp-exact-cache.sh` | Qwen3.6-27B-MTP | Exact-match prompt cache (`--cache-ram-similarity 0`) |
| `run-ik-dual-spec.sh` | Qwen3.6-27B-MTP | Dual spec: ngram-mod (self-spec) + MTP (traditional) |
| `run-ik-dual-spec-v2.sh` | Qwen3.6-27B-MTP | Dual spec v2: ngram-mod -> MTP fallback |
| `run-ik-2b.sh` | Qwen3.5-2B | Small model, unified memory |
| `run-ik-both.sh` | 27B (8080) + 2B (8081) | Launch both MTP servers simultaneously |

## Run Scripts — llama.cpp (upstream)

| Script | Description |
|--------|-------------|
| `run-llama.sh` | Qwen3.6-27B with mmproj + ngram spec decode |
| `run-llama-server.sh` | Q8 KV cache + ngram spec decoding (layer-split mode) |
| `run-llama-server-tp.sh` | Tensor parallelism (no NCCL, no spec decode) |
| `run-2b-5060.sh` | Qwen3.5-2B on RTX 5060 Ti (GPU 1) |

## Run Scripts — Other Forks

| Script | Fork | Description |
|--------|------|-------------|
| `run-turboquant.sh` | atomic-llama-cpp-turboquant | Qwen3.6-27B-UDT-MTP + NextN spec + turbo3 KV |
| `run-cpu-qwen35-4b-mtp.sh` | ik_llama.cpp (CPU) | Qwen3.5-4B-MTP CPU-only with Q8_0 KV + flash attention |

## Utility Scripts

| Script | Description |
|--------|-------------|
| `serve-both.sh` | Start both llama.cpp servers (27B on 8080, 2B on 8081) |
| `stop-servers.sh` | Stop servers via systemd (`run-ik-both.service`) |
| `server-stats.sh` | Real-time monitor (tps + GPU stats) |
| `run-bench.sh` | Run `llama-benchy` benchmark against local server |

## Test Scripts

| Script | Description |
|--------|-------------|
| `test-mtp.sh` | MTP speculative decoding benchmark (baseline vs varying draft-max) |
| `test-graph-splits.sh` | Find max 27B fit on 3090 with graph split + tensor-splits |
| `run-graph-split-test.sh` | Non-MTP Q4_K_M with graph split |
