// Requires video_trimmer package, consider using.
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;
import 'package:vibematch/functions/prompting.dart' show generateMusic;

import 'package:vibematch/components/DisplayTextFieldWidget.dart';


class PromptPage extends StatefulWidget{  
  final Map<String, dynamic> mllmResponse;
  const PromptPage({super.key, required this.mllmResponse});

  @override
  State<PromptPage> createState() => _PromptState();
}

class _PromptState extends State<PromptPage> {
  // TODO: add State variables
  late bool _isReadOnly;
  late String promptText;

  @override
  void initState() {
    // TODO: implement initState
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
    // TODO: implement build
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
            Center(
              child: DisplayTextFieldWidget(initialText: widget.mllmResponse['Content Description'], isReadOnly: true,),
            ),
            Center(
              child: DisplayTextFieldWidget(initialText: widget.mllmResponse['Music Prompt'], isReadOnly: _isReadOnly, onEdit: updatePromptText,)
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
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