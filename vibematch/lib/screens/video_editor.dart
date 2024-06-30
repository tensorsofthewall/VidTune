// Requires video_trimmer package, consider using.
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'dart:io' show File;


class VideoEditorPage extends StatefulWidget{  
  final String? selectedFilePath;
  const VideoEditorPage({super.key, required this.selectedFilePath});

  @override
  State<VideoEditorPage> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditorPage> {
  // TODO: add State variables
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadVideo();
  }
  
  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(widget.selectedFilePath.toString()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Editor")
      ),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        color: Theme.of(context).colorScheme.onPrimary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: VideoViewer(trimmer: _trimmer)
            ),
            Center(
              child: TrimViewer(
                trimmer: _trimmer,
                viewerHeight: 70.0,
                viewerWidth: MediaQuery.of(context).size.width,
                onChangeStart: (value) => _startValue = value,
                onChangeEnd: (value) => _endValue = value,
                onChangePlaybackState: (value) => setState(() {
                  _isPlaying = value;
                }),
              )
            ),
            TextButton(
              onPressed: () async {
                bool playbackState = await _trimmer.videoPlaybackControl(startValue: _startValue, endValue: _endValue);
                setState(() {
                  _isPlaying = playbackState;
                });
              },
              child: _isPlaying
              ? const Icon(
                  Icons.pause,
                  size: 80.0,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.play_arrow,
                  size: 80.0,
                  color: Colors.white,
                ),
            ),
          ],
        )

      )
    );
  }
}