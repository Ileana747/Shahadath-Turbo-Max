import modal
import subprocess
import json

# --- CONFIGURATION ---
MODEL_NAME = "Qwen/Qwen3.6-27B"  # Full model, vLLM handles quantization
GPU_CONFIG = "H100"  # Use H100 for 27B - A10G doesn't have enough VRAM
N_GPU = 1
MINUTES = 60
VLLM_PORT = 8000
IDLE_TIMEOUT = 5  # Scale to zero after 5 seconds of inactivity

# --- CONTAINER IMAGE ---
vllm_image = (
    modal.Image.from_registry("nvidia/cuda:12.9.0-devel-ubuntu22.04", add_python="3.12")
    .entrypoint([])
    .uv_pip_install(
        "vllm==0.21.0",  # Latest stable with Qwen3.6 support [citation:9][citation:10]
        "huggingface-hub==0.36.0",
        "flashinfer-python==0.5.3",
    )
    .env({"HF_XET_HIGH_PERFORMANCE": "1"})  # Faster model transfers
)

# --- PERSISTENT VOLUMES ---
hf_cache_vol = modal.Volume.from_name("huggingface-cache", create_if_missing=True)
vllm_cache_vol = modal.Volume.from_name("vllm-cache", create_if_missing=True)

app = modal.App("qwen-27b-server")

@app.function(
    image=vllm_image,
    gpu=GPU_CONFIG,
    volumes={
        "/root/.cache/huggingface": hf_cache_vol,
        "/root/.cache/vllm": vllm_cache_vol,
    },
    scaledown_window=IDLE_TIMEOUT,  # Scale to zero after 5s - you pay $0 when idle [citation:9][citation:10]
    timeout=10 * MINUTES,
    enable_memory_snapshot=True,  # GPU snapshot for fast cold starts [citation:9][citation:10]
)
@modal.concurrent(max_inputs=32)  # Handle concurrent requests
@modal.web_server(port=VLLM_PORT, startup_timeout=10 * MINUTES)
def serve():
    """Start vLLM with OpenAI-compatible API for Qwen 27B."""
    cmd = [
        "vllm", "serve",
        MODEL_NAME,
        "--served-model-name", "qwen-27b",
        "--host", "0.0.0.0",
        "--port", str(VLLM_PORT),
        "--uvicorn-log-level=info",
        "--tensor-parallel-size", str(N_GPU),
        "--gpu-memory-utilization", "0.9",
        "--max-model-len", "262144",  # Full Qwen context length [citation:5][citation:7]
        "--max-num-seqs", "2",
        "--max-num-batched-tokens", "262144",
        # Reasoning support - Qwen3.6 has built-in reasoning [citation:5][citation:6][citation:7]
        "--reasoning-parser", "qwen3",
        # Tool calling support [citation:5][citation:6][citation:7]
        "--enable-auto-tool-choice",
        "--tool-call-parser", "qwen3_coder",
        # MTP speculative decoding for better throughput [citation:5][citation:8]
        "--speculative-config",
        f"'{{'method': 'qwen3_next_mtp', 'num_speculative_tokens': 2}}'",
        "--enforce-eager",  # Faster cold starts
    ]
    subprocess.Popen(" ".join(cmd), shell=True)