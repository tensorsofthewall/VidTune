import os
import warnings

warnings.simplefilter("ignore")
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
import torch
import numpy as np
from audiocraft.models import musicgen
from scipy.io.wavfile import write as wav_write

try:
    from logger import logging
except:
    import logging


class GenerateAudio:
    def __init__(self, model="musicgen-stereo-small"):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model_name = self.get_model_name(model)
        self.model = self.get_model(self.model_name, self.device)

    @staticmethod
    def get_model(model, device):
        try:
            model = musicgen.MusicGen.get_pretrained(model, device=device)
            logging.info(f"Loaded model: {model}")
            return model
        except Exception as e:
            logging.error(f"Failed to load model: {e}")
            raise ValueError(f"Failed to load model: {e}")
            return

    @staticmethod
    def get_model_name(model_name):
        if model_name.startswith("facebook/"):
            return model_name
        return f"facebook/{model_name}"

    def generate_audio(self, prompts, duration=30):
        try:
            self.model.set_generation_params(duration=duration)
            result = self.model.generate(prompts, progress=False)
            result = result.squeeze().cpu().numpy().T
            sample_rate = self.model.sample_rate
            logging.info(
                f"Generated audio with shape: {result.shape}, sample rate: {sample_rate} Hz"
            )
            return sample_rate, result
        except Exception as e:
            logging.error(f"Failed to generate audio: {e}")
            raise ValueError(f"Failed to generate audio: {e}")
    



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
