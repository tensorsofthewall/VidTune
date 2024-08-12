import os
from warnings import simplefilter
import traceback

simplefilter("ignore")
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
import json
import time
import google.generativeai as genai

try:
    from logger import logging
except:
    import logging

music_prompt_examples = """
'A dynamic blend of hip-hop and orchestral elements, with sweeping strings and brass, evoking the vibrant energy of the city',
'Smooth jazz, with a saxophone solo, piano chords, and snare full drums',
'90s rock song with electric guitar and heavy drums, nightcore, 140bpm',
'lofi melody loop, A minor, 110 bpm, jazzy chords evoking a feeling of curiosity, relaxing, vinyl recording',
'J-Pop, 140bpm, 320kbps, 48kHz',
'funk, disco, R&B, AOR, soft rock, and boogie',
'a light and cheerly EDM track, with syncopated drums, aery pads, and strong emotions bpm: 130'.
"""

json_schema = """
{"Content Description": "string", "Music Prompt": "string"}
"""

gemini_instructions = f"""
You are a music supervisor who analyzes the content and tone of images and videos to describe music that fits well with the mood, evokes emotions, and enhances the narrative of the visuals. Given an image or video, describe the scene and generate a prompt suitable for music generation models. Generate a music prompt based on the description, and use keywords if provided by the user:

{music_prompt_examples}

You must return your response using this JSON schema: {json_schema}
"""


class DescribeVideo:
    def __init__(self, model="flash", google_api_key=None):
        self.model = self.get_model_name(model)
        __api_key = google_api_key # self.load_api_key()
        self.is_safety_set = False
        self.safety_settings = self.get_safety_settings()

        genai.configure(api_key=__api_key)
        self.mllm_model = genai.GenerativeModel(
            self.model, system_instruction=gemini_instructions
        )

        logging.info(f"Initialized DescribeVideo with model: {self.model}")

    def describe_video(self, video_path, genre, bpm, user_keywords):
        video_file = genai.upload_file(video_path)

        while video_file.state.name == "PROCESSING":
            time.sleep(0.25)
            video_file = genai.get_file(video_file.name)

        if video_file.state.name == "FAILED":
            logging.error(
                f"Failed to upload video: {video_file.state.name}, Traceback: {traceback.format_exc()}"
            )
            raise ValueError(f"Failed to upload video: {video_file.state.name}")

        additional_keywords = ", ".join(filter(None, [genre, user_keywords])) + (
            f", {bpm} bpm" if bpm else ""
        )

        logging.info(f"Uploaded video: {video_path} and config: {additional_keywords}")

        user_prompt = "Explain what is happening in this video."

        if additional_keywords:
            user_prompt += f" The following keywords are provided by the user for generating the music prompt: {additional_keywords}"

        response = self.mllm_model.generate_content(
            [video_file, user_prompt],
            request_options={"timeout": 600},
            safety_settings=self.safety_settings,
        )

        logging.info(f"Generated : {video_path} with response: {response.text}")

        return json.loads(response.text.strip("```json\n"))

    def __call__(self, video_path):
        return self.describe_video(video_path)

    def reset_safety_settings(self):
        logging.info("Resetting safety settings")
        self.is_safety_set = False
        self.safety_settings = self.get_safety_settings()

    def set_safety_settings(self, safety_settings):
        self.safety_settings = safety_settings
        # Sanity Checks
        if not isinstance(safety_settings, dict):
            raise ValueError("Safety settings must be a dictionary")
        for harm_category, harm_block_threshold in safety_settings.items():
            if harm_category not in genai.types.HarmCategory.__members__:
                raise ValueError(f"Invalid harm category: {harm_category}")
            if harm_block_threshold not in genai.types.HarmBlockThreshold.__members__:
                raise ValueError(
                    f"Invalid harm block threshold: {harm_block_threshold}"
                )

        logging.info(f"Set safety settings: {safety_settings}")
        self.safety_settings = safety_settings
        self.is_safety_set = True

    def get_safety_settings(self):
        default_safety_settings = {
            genai.types.HarmCategory.HARM_CATEGORY_HATE_SPEECH: genai.types.HarmBlockThreshold.BLOCK_NONE,
            genai.types.HarmCategory.HARM_CATEGORY_HARASSMENT: genai.types.HarmBlockThreshold.BLOCK_NONE,
            genai.types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: genai.types.HarmBlockThreshold.BLOCK_NONE,
            genai.types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: genai.types.HarmBlockThreshold.BLOCK_NONE,
        }

        if self.is_safety_set:
            return self.safety_settings

        return default_safety_settings

    @staticmethod
    def load_api_key(path="./creds.json"):
        with open(path) as f:
            creds = json.load(f)

        api_key = creds.get("google_api_key", None)
        if api_key is None or not isinstance(api_key, str):
            logging.error(
                f"Google API key not found in {path}, Traceback: {traceback.format_exc()}"
            )
            raise ValueError(f"Gemini API key not found in {path}")
        return api_key

    @staticmethod
    def get_model_name(model):
        models = {
            "flash": "models/gemini-1.5-flash-latest",
            "pro": "models/gemini-1.5-pro-latest",
        }

        if model not in models:
            logging.error(
                f"Invalid model name '{model}'. Valid options are: {', '.join(models.keys())}, Traceback: {traceback.format_exc()}"
            )
            raise ValueError(
                f"Invalid model name '{model}'. Valid options are: {', '.join(models.keys())}"
            )

        logging.info(f"Selected model: {models[model]}")
        return models[model]


if __name__ == "__main__":
    video_path = "videos/3A49B385FD4A8FE2E3AEEF43C140D9AF_video_dashinit.mp4"
    dv = DescribeVideo(model="flash")
    video_description = dv.describe_video(video_path)
    print(video_description)
