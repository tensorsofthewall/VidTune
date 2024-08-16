import gradio as gr
from engine import DescribeVideo, GenerateAudio
from moviepy.editor import VideoFileClip, AudioFileClip, CompositeAudioClip
from moviepy.audio.fx.volumex import volumex
import shutil, tempfile, os

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

# Methods for Gradio state updates
def on_advanced_change(state):
    return gr.Accordion(open=state, visible=state)

def upload_file(file):
    return gr.Video(file.name, label=file.name, height=640, show_download_button=False, show_label=False, visible=True)

def on_vdc_change(content):
    return gr.Textbox(content, label="Video Description", visible=True)

def on_mp_change(content):
    return gr.Textbox(content, label="Music Prompt", visible=True)

# Global state variables for Gradio
video_duration = 0
audio_paths = None


# Function to generate unique directory for each session
def create_session_dir():
    return tempfile.mkdtemp()

# Function to clean up the session directory
def cleanup_session_dir():
    if os.path.exists(session_dir):
        shutil.rmtree(session_dir, ignore_errors=True)
        
def on_select_dropdown(value, evt: gr.EventData):
    if value > 0:
        orig_clip_vol = gr.Slider(minimum=0, maximum=200, value=100, label="Original Audio Volume (%)", visible=True, interactive=True, step=1)
        
        generated_audio_vol = gr.Slider(minimum=0, maximum=200, value=100, label="Generated Music Volume (%)", visible=True, interactive=True, step=1)
        mix_music_button = gr.Button("Add Generated Music to Video", visible=True, interactive=True)
        return orig_clip_vol, generated_audio_vol, mix_music_button
    else:
        return gr.Slider(minimum=0, maximum=200, value=100, label="Original Audio Volume (%)", visible=False, interactive=False, step=1), gr.Slider(minimum=0, maximum=200, value=100, label="Generated Music Volume (%)", visible=False, interactive=False, step=1), gr.Button(visible=False, interactive=False)
    
# Video Description Generation
def generate_video_description(video_descriptor, google_api_key, toggle_advanced, video_file, genre, bpm, user_keywords):
    global video_duration
    try:
        if google_api_key == "":
            raise gr.Error("Please enter your Google API Key before continuing!")
        if video_file is None:
            raise gr.Error("Please upload a video before generating music.")
        video_descriptor = DescribeVideo(
            model=video_model_map[video_descriptor], google_api_key=google_api_key
        )
        
        if not toggle_advanced:
            video_description = video_descriptor.describe_video(
                video_file, genre=None, 
                bpm=None,
                user_keywords=None
            )
        else:
            video_description = video_descriptor.describe_video(
                video_file, genre=genre, 
                bpm=bpm,
                user_keywords=user_keywords
            )
        video_duration = VideoFileClip(video_file).duration
        
        gr.Info("Video Description generated successfully.")
        gr.Info("Music Prompt generated successfully.")
        
        # Return the updated states to update the UI
        return video_description["Content Description"], video_description["Music Prompt"]
    
    except Exception as e:
        raise gr.Error("Exception raised: ", e)
    
def generate_music(music_generator, music_prompt, num_samples):
    global video_duration, audio_paths, session_dir
    try:
        audio_generator = GenerateAudio(model=music_model_map[music_generator])
        if audio_generator.device == "cpu":
            gr.Warning("The music generator model is running on CPU. For faster results, consider using a GPU.") 
        
        music_prompt = [music_prompt] * num_samples
        audio_generator.generate_audio(music_prompt, duration=video_duration)
        audio_paths = audio_generator.save_audio(audio_dir=session_dir)
        
        gr.Info("Music generated successfully.")
        
        show_players = [gr.Audio(visible=True, value=audio_path, show_label=False, scale=0.5) for audio_path in audio_paths]
        hide_players = [gr.Audio(visible=False) for _ in range(5-len(audio_paths))]
        
        dropdown_choices = ["None"] + [f"Generated Music {i+1}" for i in range(len(show_players))]
        selections = gr.Dropdown(choices=dropdown_choices, visible=True, interactive=True, label="Select one of the generated audio files for further processing:", value="None", type='index')
        
        return show_players + hide_players + [selections]
    except Exception as e:
        raise gr.Error("Exception raised: ",e)


def mix_music_with_video(video_file, dropdown_index, orig_clip_vol, generated_audio_vol):
    global session_dir, audio_paths
    orig_clip = VideoFileClip(video_file)
    print(video_file)
    print(orig_clip)
    orig_clip_audio = orig_clip.audio
    generated_audio = AudioFileClip(audio_paths[dropdown_index-1])
    
    if orig_clip_audio:
        orig_clip_audio = volumex(
            orig_clip_audio, float(orig_clip_vol / 100)
        )
    
    if generated_audio:
        generated_audio = volumex(
            generated_audio, float(generated_audio_vol / 100)
        )
    
    if orig_clip_audio is not None:
        orig_clip.audio = CompositeAudioClip([orig_clip_audio, generated_audio])
    else:
        orig_clip.audio = CompositeAudioClip([generated_audio])
    
    final_video_path = f"{session_dir}/final_video.mp4"
    orig_clip.write_videofile(final_video_path)
    
    orig_clip.close()
    generated_audio.close()
    
    return gr.Video(final_video_path, height=640, show_download_button=False, show_label=False, visible=True), gr.DownloadButton("Download final video", value=final_video_path, visible=True, interactive=True)


with gr.Blocks(delete_cache=(1800, 3600)) as demo:
    # Create session-specific temp dir
    session_dir = create_session_dir()
    
    toggle_advanced = gr.State(False)
    with gr.Row():
        with gr.Column(scale=1) as sideBar:
            google_api_key = gr.Textbox(label="Enter your Google API Key to get started:", info="https://ai.google.dev/gemini-api/docs/api-key", type="password")
            video_descriptor = gr.Dropdown(["Fast", "Quality"], label="Select Video Descriptor", value="Fast", interactive=True)
            music_generator = gr.Dropdown(["Fast", "Balanced", "Quality"], label="Select Music Generator", value="Fast", interactive=True)
            num_samples = gr.Slider(minimum=1, maximum=5, value=3, label="Number of samples", interactive=True, step=1)
            
            advanced_settings_btn = gr.Button("Advanced")
            with gr.Accordion(open=False, visible=False) as advanced_settings:
                bpm = gr.Slider(minimum=35, maximum=180, value=100, label="Beats Per Minute", interactive=True, step=1)
                genre = gr.Dropdown(choices=[
                    "None",
                    "Pop",
                    "Rock",
                    "Hip Hop",
                    "Jazz",
                    "Classical",
                    "Blues",
                    "Country",
                    "EDM",
                    "Metal",
                    "Disco",
                    "Lo-Fi"
                    ], value="None", interactive=True, label="Select Music Genre"
                )
                user_keywords = gr.Textbox(label="User Keywords", type="text", info="Enter keywords separated by commas")
            
            generate_music_btn = gr.Button("Generate Music")
            
            toggle_advanced.change(on_advanced_change, inputs=toggle_advanced, outputs=[advanced_settings])
            
            advanced_settings_btn.click(lambda x: not x, toggle_advanced, toggle_advanced)
            
        
        with gr.Column(scale=3.5) as MainWindow:
            gr.Image("assets/VidTune-Logo-Without-BG.png", width=200, interactive=False, show_download_button=False, show_label=False)
            gr.Markdown(
                """
                <div style="font-size: 35px; font-weight: bold;">VidTune: Where Videos Find Their Melody</div>
                <p>VidTune is a web application to effortlessly tailor perfect soundtracks for your videos with AI.</p>
                """,
            )
            uploaded_file = gr.UploadButton(label="Upload Video (Limit 200MB)", file_count="single", type="filepath", file_types=["video"])
            
            video_file = gr.Video(height=640, show_download_button=False, show_label=False, visible=False)
            
            video_description_box = gr.Textbox(label="Video Description", visible=True)
            music_prompt_box = gr.Textbox(label="Music Prompt", visible=True)
            
            audio_players = [gr.Audio(visible=False) for _ in range(5)]
            audio_players_selections = gr.Dropdown(choices=["None"], visible=False, interactive=False, label="")
            
            orig_clip_vol=  gr.Slider(minimum=0, maximum=200, value=100, label="Original Audio Volume (%)", visible=False, interactive=False, step=1)
            
            generated_audio_vol = gr.Slider(minimum=0, maximum=200, value=100, label="Generated Music Volume (%)", visible=False, interactive=False, step=1)
            
            mix_music_button = gr.Button(visible=False)
            
            output_video = gr.Video(height=640, show_download_button=False, show_label=False, visible=False)
            
            download_video_btn = gr.DownloadButton(visible=False, interactive=False)
            
            uploaded_file.upload(upload_file, uploaded_file, video_file)
            
            generate_music_btn.click(
                generate_video_description, 
                inputs=[video_descriptor, google_api_key, toggle_advanced, video_file, genre, bpm, user_keywords],
                outputs=[video_description_box, music_prompt_box]
            ).success(generate_music,
                   inputs=[music_generator, music_prompt_box, num_samples],
                   outputs=[*audio_players, audio_players_selections])
            
            audio_players_selections.select(on_select_dropdown, audio_players_selections, outputs=[orig_clip_vol, generated_audio_vol,mix_music_button])
            
            mix_music_button.click(
                mix_music_with_video,
                inputs = [video_file, audio_players_selections, orig_clip_vol, generated_audio_vol],
                outputs=[output_video, download_video_btn]
                
            )
        
        demo.unload(cleanup_session_dir)


if __name__ == "__main__":
    demo.launch(max_file_size="200mb")
