import os
import warnings

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
warnings.simplefilter("ignore")
import argparse
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import torch
from torch.cuda import memory_allocated, memory_reserved
from audiocraft.models import musicgen
import numpy as np
import io
from fastapi.responses import StreamingResponse, JSONResponse
from scipy.io.wavfile import write as wav_write
import uvicorn
import psutil
from logger import logging


# Parse command line arguments
parser = argparse.ArgumentParser(description="Music Generation Server")
parser.add_argument(
    "--model", type=str, default="musicgen-stereo-small", help="Pretrained model name"
)
parser.add_argument(
    "--device", type=str, default="cuda", help="Device to load the model on"
)
parser.add_argument(
    "--duration", type=int, default=10, help="Duration of generated music in seconds"
)
parser.add_argument(
    "--host", type=str, default="0.0.0.0", help="Host to run the server on"
)
parser.add_argument("--port", type=int, default=8000, help="Port to run the server on")

args = parser.parse_args()


# Initialize the FastAPI app
app = FastAPI()

# Build the model name based on the provided arguments
if args.model.startswith("facebook/"):
    args.model_name = args.model
else:
    args.model_name = f"facebook/{args.model}"


logging.info(f"Initializing Model Server with Settings: {args}")

# Load the model with the provided arguments
try:
    musicgen_model = musicgen.MusicGen.get_pretrained(
        args.model_name, device=args.device
    )
    model_loaded = True
    logging.info(f"Model Loaded: {args.model_name}")
except Exception as e:
    logging.error(f"Failed to load model: {e}")
    musicgen_model = None
    model_loaded = False


class MusicRequest(BaseModel):
    prompts: List[str]
    duration: Optional[int] = 10  # Default duration is 10 seconds if not provided


@app.get("/generate_music")
def generate_music(request: MusicRequest):

    if not model_loaded:
        raise HTTPException(status_code=500, detail="Model is not loaded.")

    try:
        logging.info(
            f"Generating music with prompts: {request.prompts}, duration: {request.duration} seconds"
        )

        musicgen_model.set_generation_params(duration=request.duration)
        result = musicgen_model.generate(request.prompts, progress=False)
        result = result.squeeze().cpu().numpy().T

        sample_rate = musicgen_model.sample_rate

        logging.info(
            f"Music generated with shape: {result.shape}, sample rate: {sample_rate} Hz"
        )

        buffer = io.BytesIO()
        wav_write(buffer, sample_rate, result)
        buffer.seek(0)
        return StreamingResponse(buffer, media_type="audio/wav")
    except Exception as e:
        logging.error(f"Failed to generate music: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
def health_check():
    cpu_usage = psutil.cpu_percent(interval=1)
    ram_usage = psutil.virtual_memory().percent
    stats = {
        "server_running": True,
        "model_loaded": model_loaded,
        "cpu_usage_percent": cpu_usage,
        "ram_usage_percent": ram_usage,
    }
    if args.device == "cuda" and torch.cuda.is_available():
        gpu_memory_allocated = memory_allocated()
        gpu_memory_reserved = memory_reserved()
        stats.update(
            {
                "gpu_memory_allocated": gpu_memory_allocated,
                "gpu_memory_reserved": gpu_memory_reserved,
            }
        )

    logging.info(f"Health Check: {stats}")

    return JSONResponse(content=stats)


if __name__ == "__main__":
    uvicorn.run("main:app", host=args.host, port=args.port, reload=False, workers=1)
