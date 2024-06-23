import warnings
import argparse
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import torch
from audiocraft.models import musicgen
import numpy as np
import io
from fastapi.responses import StreamingResponse
from scipy.io.wavfile import write as wav_write
import uvicorn

warnings.simplefilter('ignore')

# Parse command line arguments
parser = argparse.ArgumentParser(description="Music Generation Server")
parser.add_argument("--model", type=str, default="musicgen-stereo-small", help="Pretrained model name")
parser.add_argument("--device", type=str, default="cuda", help="Device to load the model on")
parser.add_argument("--duration", type=int, default=10, help="Duration of generated music in seconds")
parser.add_argument("--host", type=str, default="0.0.0.0", help="Host to run the server on")
parser.add_argument("--port", type=int, default=8000, help="Port to run the server on")

args = parser.parse_args()

# Initialize the FastAPI app
app = FastAPI()

# Build the model name based on the provided arguments
if args.model.startswith('facebook/'):
    args.model_name = args.model
else:
    args.model_name = f"facebook/{args.model}"

# Load the model with the provided arguments
musicgen_model = musicgen.MusicGen.get_pretrained(args.model_name, device=args.device)

class MusicRequest(BaseModel):
    prompts: List[str]
    duration: Optional[int] = 10  # Default duration is 10 seconds if not provided

@app.post("/generate_music")
def generate_music(request: MusicRequest):
    try:
        musicgen_model.set_generation_params(duration=request.duration)
        result = musicgen_model.generate(request.prompts, progress=False)
        result = result.squeeze().cpu().numpy().T
        
        sample_rate = musicgen_model.sample_rate
        
        buffer = io.BytesIO()
        wav_write(buffer, sample_rate, result)

        buffer.seek(0)
        
        return StreamingResponse(buffer, media_type="audio/wav")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host=args.host, port=args.port)
