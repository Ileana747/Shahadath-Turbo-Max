import modal
import subprocess

app = modal.App("qwen-27b-server")

# --- FIX: Compatible versions ---
vllm_image = (
    modal.Image.from_registry("nvidia/cuda:12.9.0-devel-ubuntu22.04", add_python="3.12")
    .entrypoint([])
    .uv_pip_install(
        "vllm==0.21.0",
        "huggingface-hub==0.36.0",
    )
    # No flashinfer - vLLM 0.21.0 now bundles it correctly
)

hf_cache_vol = modal.Volume.from_name("huggingface-cache", create_if_missing=True)
vllm_cache_vol = modal.Volume.from_name("vllm-cache", create_if_missing=True)

app = modal.App("qwen-27b-server")

@app.function(
    image=vllm_image,
    gpu="A10G",  # 24GB VRAM
    volumes={
        "/root/.cache/huggingface": hf_cache_vol,
        "/root/.cache/vllm": vllm_cache_vol,
    },
    scaledown_window=5,
    timeout=600,
    enable_memory_snapshot=True,
)
@modal.concurrent(max_inputs=32)
@modal.web_server(port=8000, startup_timeout=600)
def serve():
    cmd = [
        "vllm", "serve",
        "shawnw3i/Huihui-Qwen3.6-27B-abliterated-AWQ-MTP",
        "--served-model-name", "qwen-27b",
        "--host", "0.0.0.0",
        "--port", "8000",
        "--uvicorn-log-level=info",
        "--max-model-len", "65536",  # AWQ version supports 65K
        "--reasoning-parser", "qwen3",
        "--enable-auto-tool-choice",
        "--tool-call-parser", "qwen3_coder",
        "--speculative-config", '{"method":"mtp","num_speculative_tokens":3}',
        "--enforce-eager",
    ]
    subprocess.Popen(" ".join(cmd), shell=True)