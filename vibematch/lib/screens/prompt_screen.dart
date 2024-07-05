// Requires video_trimmer package, consider using.

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vibematch/functions/prompting.dart' show generateMusic; //generateMusicZT

import 'package:vibematch/components/DisplayTextFieldWidget.dart';
import 'package:vibematch/screens/audiogen_screen.dart';


class PromptPage extends StatefulWidget{  
  final Map<String, dynamic> mllmResponse;
  final int videoDuration;
  const PromptPage({super.key, required this.mllmResponse, required this.videoDuration});

  @override
  State<PromptPage> createState() => _PromptState();
}

class _PromptState extends State<PromptPage> {
  late bool _isReadOnly;
  late String promptText;

  @override
  void initState() {
    super.initState();
    _isReadOnly = false;
    promptText = widget.mllmResponse['Music Prompt'];
  }

  void updatePromptText(String? updatedText) {
    setState(() {
      promptText = updatedText.toString();
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Content Description | Prompt")
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: <Widget>[
            const Text("Video Description"),
            Center(
              child: DisplayTextFieldWidget(initialText: widget.mllmResponse['Content Description'], isReadOnly: true,),
            ),
            const Text("Music Prompt/Description"),
            Center(
              child: DisplayTextFieldWidget(initialText: widget.mllmResponse['Music Prompt'], isReadOnly: _isReadOnly, onEdit: updatePromptText,)
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isReadOnly = true;
                  });
                  List<Response> audioResponses = await Future.wait([
                    generateMusic([promptText], widget.videoDuration),
                    generateMusic([promptText], widget.videoDuration),
                    generateMusic([promptText], widget.videoDuration),
                  ]);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AudioGenPage(audioResponses: audioResponses);
                    }));
                },
                child: const Text("Generate Music"),
              ),
            ),
          ],
        )

      ),
    );
  }
}