import streamlit as st
from engine import DescribeVideo, GenerateAudio
import os
from moviepy.editor import VideoFileClip, AudioFileClip, CompositeAudioClip
from moviepy.audio.fx.volumex import volumex
from streamlit.runtime.scriptrunner import get_script_run_ctx

def get_session_id():
    session_id = get_script_run_ctx().session_id
    session_id = session_id.replace('-','_')
    session_id = '_id_' + session_id
    return session_id

print(get_session_id())
# Define model maps
video_model_map = {
    "Fast": "flash",
    "Quality": "pro",
}

music_model_map = {
    "Fast": "musicgen-stereo-small",
    "Balanced": "musicgen-stereo-medium",
    "Quality": "musicgen-stereo-large",
}

# music_model_map = {
#     "Fast": "facebook/musicgen-melody",
#     "Quality": "facebook/musicgen-melody-large",
# }

genre_map = {
    "None": None,
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

# Streamlit page configuration
st.set_page_config(
    page_title="VidTune: Where Videos Find Their Melody", layout="centered"
)

# Title and Description
st.title("VidTune: Where Videos Find Their Melody")
st.write(
    "VidTune is a web application that allows users to upload videos and generate melodies matching the mood of the video."
)

# Initialize session state for advanced settings and other inputs
if "show_advanced" not in st.session_state:
    st.session_state.show_advanced = False
if "video_model" not in st.session_state:
    st.session_state.video_model = "Fast"
if "music_model" not in st.session_state:
    st.session_state.music_model = "Fast"
if "num_samples" not in st.session_state:
    st.session_state.num_samples = 3
if "music_genre" not in st.session_state:
    st.session_state.music_genre = None
if "music_bpm" not in st.session_state:
    st.session_state.music_bpm = 100
if "user_keywords" not in st.session_state:
    st.session_state.user_keywords = None
if "selected_audio" not in st.session_state:
    st.session_state.selected_audio = "None"
if "audio_paths" not in st.session_state:
    st.session_state.audio_paths = []
if "selected_audio_path" not in st.session_state:
    st.session_state.selected_audio_path = None
if "orig_audio_vol" not in st.session_state:
    st.session_state.orig_audio_vol = 100
if "generated_audio_vol" not in st.session_state:
    st.session_state.generated_audio_vol = 100
    
# Sidebar
st.sidebar.title("Settings")

# Basic Settings
st.session_state.video_model = st.sidebar.selectbox(
    "Select Video Descriptor",
    ["Fast", "Quality"],
    index=["Fast", "Quality"].index(st.session_state.video_model),
)
st.session_state.music_model = st.sidebar.selectbox(
    "Select Music Generator",
    ["Fast", "Balanced", "Quality"],
    index=["Fast", "Balanced", "Quality"].index(st.session_state.music_model),
)
st.session_state.num_samples = st.sidebar.slider(
    "Number of samples", 1, 5, st.session_state.num_samples
)

# Sidebar for advanced settings
with st.sidebar:
    # Create a placeholder for the advanced settings button
    placeholder = st.empty()

    # Button to toggle advanced settings
    if placeholder.button("Advanced"):
        st.session_state.show_advanced = not st.session_state.show_advanced
        st.rerun()  # Refresh the layout after button click

# Display advanced settings if enabled
if st.session_state.show_advanced:
    # Advanced settings
    st.session_state.music_bpm = st.sidebar.slider("Beats Per Minute", 35, 180, 100)
    st.session_state.music_genre = st.sidebar.selectbox(
        "Select Music Genre",
        list(genre_map.keys()),
        index=(
            list(genre_map.keys()).index(st.session_state.music_genre)
            if st.session_state.music_genre in genre_map.keys()
            else 0
        ),
    )
    st.session_state.user_keywords = st.sidebar.text_input(
        "User Keywords",
        value=st.session_state.user_keywords,
        help="Enter keywords separated by commas.",
    )
else:
    st.session_state.music_genre = None
    st.session_state.music_bpm = None
    st.session_state.user_keywords = None

# Generate Button
generate_button = st.sidebar.button("Generate Music")


# Cache the model loading
@st.cache_resource
def load_models(video_model_key, music_model_key):
    video_descriptor = DescribeVideo(model=video_model_map[video_model_key])
    audio_generator = GenerateAudio(model=music_model_map[music_model_key])
    return video_descriptor, audio_generator


# Load models
video_descriptor, audio_generator = load_models(
    st.session_state.video_model, st.session_state.music_model
)

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
if generate_button:
    if uploaded_video is None:
        st.error("Please upload a video before generating music.")
        st.stop()

    with st.spinner("Analyzing video..."):
        video_description = video_descriptor.describe_video(
            "temp.mp4",
            genre=st.session_state.music_genre,
            bpm=st.session_state.music_bpm,
            user_keywords=st.session_state.user_keywords,
        )
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
        if video_duration > 30:
            st.warning(
                "Due to hardware limitations, the maximum music length is capped at 30 seconds."
            )
        music_prompt = [music_prompt] * st.session_state.num_samples
        audio_generator.generate_audio(music_prompt, duration=video_duration)
        st.session_state.audio_paths = audio_generator.save_audio()
        st.success("Music generated successfully.")
        st.balloons()

# Callback function for radio button selection change
def on_audio_selection_change():
    selected_index = audio_options.index(st.session_state.selected_audio) - 1
    if selected_index >= 0:
        st.session_state.selected_audio_path = st.session_state.audio_paths[selected_index]
    else:
        st.session_state.selected_audio_path = None

# Display radio buttons and handle audio selections
if st.session_state.audio_paths:
    for i, audio_path in enumerate(st.session_state.audio_paths):
        st.audio(audio_path, format="audio/wav")
    
    audio_options = ["None"]+[f"Sample {i+1}" for i in range(len(st.session_state.audio_paths))]
    st.radio(
        "Select one of the generated audio files for further processing:",
        audio_options,
        index=0,
        key="selected_audio",
        on_change=on_audio_selection_change
    )
    
    if st.session_state.selected_audio_path:
        st.write(f"**Selected Audio:** {st.session_state.selected_audio_path}")

# Handle Audio Mixing and Export
if st.session_state.selected_audio_path is not None:
    orig_clip = VideoFileClip("temp.mp4")
    orig_clip_audio = orig_clip.audio
    generated_audio = AudioFileClip(st.session_state.selected_audio_path)
    
    st.session_state.orig_audio_vol = st.slider(
        "Original Audio Volume", 0, 200, st.session_state.orig_audio_vol
    )
    
    st.session_state.generated_audio_vol = st.slider(
        "Selected Sample Volume", 0, 200, st.session_state.generated_audio_vol
    )
    
    orig_clip_audio = volumex(orig_clip_audio, float(st.session_state.orig_audio_vol/100))
    generated_audio = volumex(generated_audio, float(st.session_state.generated_audio_vol/100))
    
    orig_clip.audio = CompositeAudioClip([orig_clip_audio, generated_audio])
    
    final_video_path="out_tmp.mp4"
    orig_clip.write_videofile(final_video_path)
    
    orig_clip.close()
    generated_audio.close()
    
    st.session_state.final_video_path = final_video_path
    
    st.video(final_video_path)
    
    if st.session_state.final_video_path:
        with open(st.session_state.final_video_path, "rb") as video_file:
            st.download_button(
                label="Download final video",
                data=video_file,
                file_name="final_video.mp4",
                mime="video/mp4",
            )