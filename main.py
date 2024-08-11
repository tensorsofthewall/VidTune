import streamlit as st
from engine import DescribeVideo, GenerateAudio
import os
import time
from moviepy.editor import VideoFileClip


video_model_map = {
    "Fast": "flash",
    "Quality": "pro",
}

music_model_map = {
    "Fast": "musicgen-stereo-small",
    "Balanced": "musicgen-stereo-medium",
    "Quality": "musicgen-stereo-large",
}

genre_map = {
    "Pop": "Pop",
    "Rock": "Rock",
    "Hip Hop": "Hip-Hop/Rap",
    "Jazz": "Jazz",
    "Classical": "Classical",
    "Blues": "Blues",
    "Country": "Country",
    "EDM": "Electronic/Dance",
    "Metal": "Metal",
    "Disco": "Disco",
    "Lo-Fi": "Lo-Fi",
}


st.set_page_config(
    page_title="VidTune: Where Videos Find Their Melody", layout="centered"
)

# Title and Description
st.title("VidTune: Where Videos Find Their Melody")
st.write(
    "VidTune is a web application that allows users to upload videos and generate melodies matching the mood of the video."
)


# Sidebar
st.sidebar.title("Settings")
video_model = st.sidebar.selectbox(
    "Select Video Descriptor", ["Fast", "Quality"], index=0
)
music_model = st.sidebar.selectbox(
    "Select Music Generator", ["Fast", "Balanced", "Quality"], index=0
)
music_genre = st.sidebar.selectbox("Select Music Genre", list(genre_map.keys()))
num_samples = st.sidebar.slider("Number of samples", 1, 5, 3)
generate_button = st.sidebar.button("Generate Music")

video_descriptor = None
audio_descriptor = None
video_description = None

# Initialize Video Descriptor and Audio Generator
if video_descriptor is None or audio_descriptor is None:
    video_descriptor = DescribeVideo(model=video_model_map[video_model])
    audio_generator = GenerateAudio(model=music_model_map[music_model])


# Video Uploader
uploaded_video = st.file_uploader("Upload Video", type=["mp4"])
if uploaded_video is not None:
    st.session_state.uploaded_video = uploaded_video
    with open("temp.mp4", mode="wb") as w:
        w.write(uploaded_video.getvalue())

# Video Player
if os.path.exists("temp.mp4") and uploaded_video is not None:
    st.video(uploaded_video)

# Submit button if video is not uploaded
if generate_button and uploaded_video is None:
    st.error("Please upload a video before generating music.")
    st.stop()


# Submit Button and music generation if video is uploaded
if generate_button and uploaded_video is not None:
    with st.spinner("Analyzing video..."):
        video_description = video_descriptor.describe_video("temp.mp4")
        video_duration = VideoFileClip("temp.mp4").duration
        music_prompt = video_description["Music Prompt"]

        st.success("Video description generated successfully.")

        # Display Video Description and Music Prompt
        st.text_area(
            "Video Description",
            video_description["Content Description"],
            disabled=True,
            height=120,
        )
        music_prompt = st.text_area(
            "Music Prompt",
            music_prompt,
            disabled=False,
            height=120,
        )

    # Generate Music
    with st.spinner("Generating music..."):
        music_prompt = [music_prompt] * num_samples
        audio_generator.generate_audio(music_prompt, duration=video_duration)
        audio_paths = audio_generator.save_audio()
        st.success("Music generated successfully.")
        for i, audio_path in enumerate(audio_paths):
            st.audio(audio_path, format="audio/wav")
            # st.download_button(
            #     label=f"Download Music {i+1}",
            #     data=open(audio_path, "rb"),
            #     file_name=f"Generated Music {i+1}.wav",
            #     mime="audio/wav",
            # )


# # Main Page (Page 1)
# if "page" not in st.session_state:
#     st.session_state.page = "main"

# if st.session_state.page == "main":
#     st.header("Video to Music")
#     uploaded_video = st.file_uploader("Upload Video", type=["mp4"])

#     if uploaded_video is not None:
#         st.session_state.uploaded_video = uploaded_video
#         with open("temp.mp4", mode="wb") as w:
#             w.write(uploaded_video.getvalue())
#         video_description = video_descriptor.describe_video("temp.mp4")

#         st.session_state.page = "video_to_music"

#     if st.session_state.page == "main":
#         st.header("Prompt to Music")
#         prompt = st.text_area("Prompt")
#         if generate_button:
#             st.session_state.prompt = prompt
#             st.session_state.page = "prompt_to_music"

# # Page 2a (If the user uploads a video)
# if st.session_state.page == "video_to_music":
#     st.video(st.session_state.uploaded_video)

#     st.text_area(
#         "Video Description", "This is a fixed video description", disabled=True
#     )
#     st.text_area("Music Description")

#     if generate_button:
#         st.session_state.page = "result"
#         st.session_state.device = device
#         st.session_state.num_samples = num_samples

# # Page 2b (If user selects "Prompt to Music" in Page 1)
# if st.session_state.page == "prompt_to_music":
#     st.sidebar.title("Settings")
#     device = st.sidebar.selectbox("Select Device", ["GPU", "CPU"], index=0)
#     num_samples = st.sidebar.slider("Number of samples", 1, 10, 3)

#     if generate_button:
#         st.session_state.page = "result"
#         st.session_state.device = device
#         st.session_state.num_samples = num_samples

# # Page 3 (Results Page)
# if st.session_state.page == "result":
#     st.header("Generated Music")
#     for i in range(st.session_state.num_samples):
#         st.write(f"Music Sample {i+1}")
#         st.audio(f"Generated Music {i+1}.mp3", format="audio/mp3")
#         st.download_button(f"Download Music {i+1}", f"Generated Music {i+1}.mp3")

#     if st.button("Start Over"):
#         st.session_state.page = "main"
