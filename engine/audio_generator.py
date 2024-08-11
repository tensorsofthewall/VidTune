import os
import warnings
import traceback

warnings.simplefilter("ignore")
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
import io
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
        self.generated_audio = None
        self.sampling_rate = None

    @staticmethod
    def get_model(model, device):
        try:
            model = musicgen.MusicGen.get_pretrained(model, device=device)
            logging.info(f"Loaded model: {model}")
            return model
        except Exception as e:
            logging.error(
                f"Failed to load model: {e}, Traceback: {traceback.format_exc()}"
            )
            raise ValueError(f"Failed to load model: {e}")
            return

    @staticmethod
    def get_model_name(model_name):
        if model_name.startswith("facebook/"):
            return model_name
        return f"facebook/{model_name}"

    @staticmethod
    def duration_sanity_check(duration):
        if duration < 1:
            logging.warning(
                "Duration is less than 1 second. Setting duration to 1 second."
            )
            return 1
        elif duration > 30:
            logging.warning(
                "Duration is greater than 30 seconds. Setting duration to 30 seconds."
            )
            return 30
        return duration

    @staticmethod
    def prompts_sanity_check(prompts):
        if isinstance(prompts, str):
            prompts = [prompts]
        elif not isinstance(prompts, list):
            raise ValueError("Prompts should be a string or a list of strings.")
        else:
            for prompt in prompts:
                if not isinstance(prompt, str):
                    raise ValueError("Prompts should be a string or a list of strings.")
            if len(prompts) > 8:  # Too many prompts will cause OOM error
                raise ValueError("Maximum number of prompts allowed is 8.")
        return prompts

    def generate_audio(self, prompts, duration=10):
        duration = self.duration_sanity_check(duration)
        prompts = self.prompts_sanity_check(prompts)

        try:
            self.sampling_rate = self.model.sample_rate
            if duration <= 30:
                self.model.set_generation_params(duration=duration)
                result = self.model.generate(prompts, progress=False)
            elif duration > 30:
                self.model.set_generation_params(duration=30)
                result = self.model.generate(prompts, progress=False)
                self.model.set_generation_params(duration=duration)
                result = self.model.generate_with_chroma(
                    prompts,
                    result,
                    melody_sample_rate=self.sampling_rate,
                    progress=False,
                )
            self.result = result.cpu().numpy().T
            self.result = self.result.transpose((2, 0, 1))

            logging.info(
                f"Generated audio with shape: {self.result.shape}, sample rate: {self.sampling_rate} Hz"
            )
            return self.sampling_rate, self.result
        except Exception as e:
            logging.error(
                f"Failed to generate audio: {e}, Traceback: {traceback.format_exc()}"
            )
            raise ValueError(f"Failed to generate audio: {e}")

    def save_audio(self, audio_dir="generated_audio"):
        if self.result is None:
            raise ValueError("Audio is not generated yet.")
        if self.sampling_rate is None:
            raise ValueError("Sampling rate is not available.")

        paths = []
        os.makedirs(audio_dir, exist_ok=True)
        for i, audio in enumerate(self.result):
            path = os.path.join(audio_dir, f"audio_{i}.wav")
            wav_write(path, self.sampling_rate, audio)
            paths.append(path)
        return paths

    def get_audio_buffer(self):
        if self.result is None:
            raise ValueError("Audio is not generated yet.")
        if self.sampling_rate is None:
            raise ValueError("Sampling rate is not available.")

        buffers = []
        for audio in self.result:
            buffer = io.BytesIO()
            wav_write(buffer, self.sampling_rate, audio)
            buffer.seek(0)
            buffers.append(buffer)
        return buffers


if __name__ == "__main__":
    audio_gen = GenerateAudio()
    sample_rate, result = audio_gen.generate_audio(
        [
            "A piano playing a jazz melody",
            "A guitar playing a rock riff",
            "A LoFi music for coding",
        ],
        duration=10,
    )
    paths = audio_gen.save_audio()
    print(f"Saved audio to: {paths}")
    buffers = audio_gen.get_audio_buffer()
    print(f"Audio buffers: {buffers}")
