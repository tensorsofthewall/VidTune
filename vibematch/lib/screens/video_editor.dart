// Requires video_trimmer package, consider using.
import 'dart:developer' as developer;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vibematch/functions/prompting.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'dart:io' show File;
import 'prompt_screen.dart';

class VideoEditorPage extends StatefulWidget {
  final String? selectedFilePath;
  const VideoEditorPage({super.key, required this.selectedFilePath});

  @override
  State<VideoEditorPage> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditorPage> {
  // TODO: add State variables
  final Trimmer _trimmer = Trimmer();
  late String trimFilePath;

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadVideo();
    trimFilePath = "";
  }

  // Loads video to trimmer object during init
  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(widget.selectedFilePath.toString()));
  }

  // Save trimmed video file and get filepath for query.
  Future<void> saveTrimAndGetPath(double startValue, double endValue) async {
    developer.log("Log value: $startValue, $endValue");
    await _trimmer.saveTrimmedVideo(
      startValue: startValue,
      endValue: endValue,
      outputFormat: FileFormat.mp4,
      onSave: getOutputFilePath,
      storageDir: StorageDir.temporaryDirectory,
    );
    // developer.log("out: $out");
    await Future.delayed(const Duration(seconds: 5));
    developer.log("Filepath: ${trimFilePath.toString()}");
  }

  void getOutputFilePath(String? filepath) {
    setState(() {
      trimFilePath = filepath.toString();
    });
    print("Filepath: ${trimFilePath.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text("Video Editor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        // color: Theme.of(context).colorScheme.onPrimary,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          // mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(child: VideoViewer(trimmer: _trimmer)),
            Center(
                child: TrimViewer(
              trimmer: _trimmer,
              maxVideoLength: const Duration(seconds: 30),
              viewerHeight: 70.0,
              viewerWidth: MediaQuery.of(context).size.width,
              onChangeStart: (value) => _startValue = value,
              onChangeEnd: (value) => _endValue = value,
              onChangePlaybackState: (value) => setState(() {
                _isPlaying = value;
              }),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                        startValue: _startValue, endValue: _endValue);
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 50.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 50.0,
                          color: Colors.white,
                        ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await saveTrimAndGetPath(_startValue, _endValue);
                    promptMLLM(trimFilePath, FirebaseStorage.instance.ref())
                        .then((mllmResponse) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PromptPage(mllmResponse: mllmResponse);
                      }));
                    });
                  },
                  child: const Icon(
                    Icons.generating_tokens,
                    size: 50.0,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
