<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![AGPL License][license-shield]][license-url]
[![Sandesh-LinkedIn][sandesh-linkedin-shield]][sandesh-linkedin-url]
[![Animikh-LinkedIn][animikh-linkedin-shield]][animikh-linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/sandesh-bharadwaj/VidTune">
    <img src="assets/VidTune-Logo-Without-BG.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">VidTune</h3>

  <p align="center">
    Tailored soundtracks for your videos
    <br />
    <br />
    <a href="https://github.com/sandesh-bharadwaj/VidTune/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/sandesh-bharadwaj/VidTune/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#hardware-requirements">Hardware Requirements</a>
      <ul>
        <li><a href="#hardwarre-used-for-development-and-testing">Hardware used for Development and Testing</a></li>
      </ul>
    </li>
    <li><a href="#see-vidtune-in-action">See VidTune in action!</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

![startup_screen]

**VidTune** is a generative AI application designed to create custom music tailored to your video content. By leveraging advanced AI models for video analysis and music creation, **VidTune** provides an intuitive and seamless experience for generating and integrating music into your videos.

**VidTune** employs two state-of-the-art models for video understanding and music generation:
1. [**Google Gemini**](https://ai.google.dev/gemini-api) - Google's largest and most capable multimodal AI model.
2. [**MusicGen**](https://huggingface.co/facebook/musicgen-large) - Meta's text-to-music model, capable of generating high-quality music conditioned on text or audio prompts.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With
[![Transformers][Transformers-shield]][Transformers-url]
[![Google Gemini][Google-Gemini-shield]][Google-Gemini-url]
[![AudioCraft][AudioCraft-shield]][AudioCraft-url]
[![MusicGen][MusicGen-shield]][MusicGen-url]
[![Streamlit][Streamlit-shield]][Streamlit-url]
<!-- * [![Next][Next.js]][Next-url]
* [![React][React.js]][React-url]
* [![Vue][Vue.js]][Vue-url]
* [![Angular][Angular.io]][Angular-url]
* [![Svelte][Svelte.dev]][Svelte-url]
* [![Laravel][Laravel.com]][Laravel-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url] -->

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Hardware Requirements

### Hardware used for Development and Testing

- **CPU:** AMD Ryzen 7 3700X - 8 Cores 16 Threads
- **GPU:** Nvidia GeForce RTX 4060 Ti 16 GB
- **RAM:** 64 GB DDR4 @ 3200 MHz
- **OS:** Linux (WSL | Ubuntu 22.40)

The above is just used for development and by no means is necessary to run this application. The Minimum Hardware Requirements are given in the next section

While VidTune is supported on CPU-only machines, we recommend using a GPU with minimum 16GB of memory for faster results.


## See VidTune in action!
[![Watch the video](https://img.youtube.com/vi/knbQjWZtL3Y/maxresdefault.jpg)](https://youtu.be/knbQjWZtL3Y)

## Running VidTune
First, clone the repository:
```sh
git clone https://github.com/sandesh-bharadwaj/VidTune.git
cd VidTune
```
### Using conda
If you're using conda as your virtual environment manager, do the following:
```
conda env create -f environment.yml
conda activate vidtune

streamlit run main.py
```

### Using python / pip
```
pip install -r requirements.txt
streamlit run main.py
```

### Using Docker
- [Docker](https://docs.docker.com/engine/install/)
- [Nvidia Docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt)

```
docker run --rm -it --gpus all -p 8003:8003 animikhaich/vidtune
```



<!-- ROADMAP -->
## Roadmap
- [x] Customized Prompt for Gemini Prompting
- [x] Flutter version of app for proof-of-concept
- [x] MusicGen integration
- [x] Audio Mixing
- [x] Streamlit app
- [x] Docker image
- [ ] OpenVINO-optimized versions of MusicGen for CPU-Only use.
- [ ] Support for music generation duration > 30 seconds.
- [ ] Add more settings for controlling generation.
- [ ] Option to edit music prompts before music generation.


See the [open issues](https://github.com/sandesh-bharadwaj/VIdTune/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

If you have a suggestion that would improve this, please **open an issue** with the tag *"enhancement"*.You can also **fork the repo** and create a pull request. Your feedback is greatly appreciated!
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the CC BY-NC 4.0 License. See [`LICENSE`](./LICENSE) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Sandesh Bharadwaj - sandesh.bharadwaj97@gmail.com

Animikh Aich - animikhaich@gmail.com

Project Link: [https://github.com/sandesh-bharadwaj/VidTune](https://github.com/sandesh-bharadwaj/VidTune)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* Google.
* Meta.


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/sandesh-bharadwaj/VidTune.svg?style=for-the-badge
[contributors-url]: https://github.com/sandesh-bharadwaj/VidTune/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/sandesh-bharadwaj/VidTune.svg?style=for-the-badge
[forks-url]: https://github.com/sandesh-bharadwaj/VidTune/network/members
[stars-shield]: https://img.shields.io/github/stars/sandesh-bharadwaj/VidTune.svg?style=for-the-badge
[stars-url]: https://github.com/sandesh-bharadwaj/VidTune/stargazers
[issues-shield]: https://img.shields.io/github/issues/sandesh-bharadwaj/VidTune.svg?style=for-the-badge
[issues-url]: https://github.com/sandesh-bharadwaj/VidTune/issues
[license-shield]: https://img.shields.io/github/license/sandesh-bharadwaj/VidTune.svg?style=for-the-badge
[license-url]: https://github.com/sandesh-bharadwaj/VidTune/blob/main/LICENSE
[llama-3-shield]: https://img.shields.io/badge/License-Llama%203-purple.svg?style=for-the-badge
[llama-3-license]: https://github.com/sandesh-bharadwaj/VidTune/blob/main/LLAMA-3-LICENSE
[sandesh-linkedin-shield]: https://img.shields.io/badge/-Sandesh_Bharadwaj-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[sandesh-linkedin-url]: https://linkedin.com/in/sandeshbharadwaj97
[animikh-linkedin-shield]: https://img.shields.io/badge/-Animikh_Aich-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[animikh-linkedin-url]: https://linkedin.com/in/animikh-aich
[startup_screen]: assets/homepage.png

[Python-url]: https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54
[Langchain-shield]: https://img.shields.io/badge/LangChain-0.2.12-1C3C3C?style=for-the-badge&logo=langchain
[Langchain-url]: https://github.com/langchain-ai/langchain
[Transformers-shield]: https://img.shields.io/badge/Transformers-4.42.4-blue?style=for-the-badge
[Transformers-url]: https://github.com/huggingface/transformers
[Optimum-shield]: https://img.shields.io/badge/Optimum-1.21.2-blue?style=for-the-badge
[Optimum-url]: https://github.com/huggingface/optimum
[OpenVINO-shield]: https://img.shields.io/badge/OpenVINO-2024.3-purple?style=for-the-badge
[OpenVINO-url]: https://github.com/openvinotoolkit/openvino
[Chroma-shield]: https://img.shields.io/badge/Chroma-0.5.5-blue?style=for-the-badge
[Chroma-url]: https://github.com/chroma-core/chroma

[Google-Gemini-shield]: https://img.shields.io/badge/Google%20Gemini-886FBF?style=for-the-badge&logo=googlegemini&logoColor=fff
[Google-Gemini-url]: https://ai.google.dev/gemini-api
[Streamlit-shield]: https://img.shields.io/badge/-Streamlit-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white
[Streamlit-url]: https://streamlit.io/

[AudioCraft-shield]: https://img.shields.io/badge/-AudioCraft-blue?style=for-the-badge&logo=Meta
[AudioCraft-url]: https://audiocraft.metademolab.com/
[MusicGen-shield]:https://img.shields.io/badge/-MusicGen-blue?style=for-the-badge&logo=Meta
[MusicGen-url]: https://musicgen.com/