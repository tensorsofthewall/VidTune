import streamlit as st
from engine import DescribeVideo, GenerateAudio


video_model_map = {
    "Fast": "flash",
    "Quality": "pro",
}

music_model_map = {
    "Fast": "musicgen-stereo-small",
    "Balanced": "musicgen-stereo-medium",
    "Quality": "musicgen-stereo-large",
}


st.set_page_config(page_title="VidTune: Where Videos Find Their Melody", layout="centered")

# Title and Description
st.title("VidTune: Where Videos Find Their Melody")
st.write("VidTune is a web application that allows users to upload videos and generate melodies matching the mood of the video.")


# Sidebar
st.sidebar.title("Settings")
video_model = st.sidebar.selectbox("Select Video Descriptor", ["Fast", "Balanced", "Quality"], index=0)
music_model = st.sidebar.selectbox("Select Music Generator", ["Fast", "Balanced", "Quality"], index=0)
num_samples = st.sidebar.slider("Number of samples", 1, 8, 3)
generate_button = st.sidebar.button("Generate Music")

video_descriptor = DescribeVideo(model=video_model_map[video_model])
audio_generator = GenerateAudio(model=music_model_map[music_model])

video_description = None

# Main Page (Page 1)
if 'page' not in st.session_state:
    st.session_state.page = 'main'

if st.session_state.page == 'main':
    st.header("Video to Music")
    uploaded_video = st.file_uploader("Upload Video", type=["mp4"])
    
    if uploaded_video is not None:
        st.session_state.uploaded_video = uploaded_video
        with open("temp.mp4", mode='wb') as w:
            w.write(uploaded_video.getvalue())
        video_description = video_descriptor.describe_video("temp.mp4")
        
        st.session_state.page = 'video_to_music'
    
    if st.session_state.page == 'main':
        st.header("Prompt to Music")
        prompt = st.text_area("Prompt")
        if generate_button:
            st.session_state.prompt = prompt
            st.session_state.page = 'prompt_to_music'

# Page 2a (If the user uploads a video)
if st.session_state.page == 'video_to_music':    
    st.video(st.session_state.uploaded_video)
    
    st.text_area("Video Description", "This is a fixed video description", disabled=True)
    st.text_area("Music Description")
    
    if generate_button:
        st.session_state.page = 'result'
        st.session_state.device = device
        st.session_state.num_samples = num_samples

# Page 2b (If user selects "Prompt to Music" in Page 1)
if st.session_state.page == 'prompt_to_music':
    st.sidebar.title("Settings")
    device = st.sidebar.selectbox("Select Device", ["GPU", "CPU"], index=0)
    num_samples = st.sidebar.slider("Number of samples", 1, 10, 3)
    
    if generate_button:
        st.session_state.page = 'result'
        st.session_state.device = device
        st.session_state.num_samples = num_samples

# Page 3 (Results Page)
if st.session_state.page == 'result':
    st.header("Generated Music")
    for i in range(st.session_state.num_samples):
        st.write(f"Music Sample {i+1}")
        st.audio(f"Generated Music {i+1}.mp3", format='audio/mp3')
        st.download_button(f"Download Music {i+1}", f"Generated Music {i+1}.mp3")
    
    if st.button("Start Over"):
        st.session_state.page = 'main'