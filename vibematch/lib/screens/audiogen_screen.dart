// Screen for receiving generated audio and displaying controls and stuff.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart';
import 'package:audioplayers/audioplayers.dart';


class AudioGenPage extends StatefulWidget{
  final List<Response> audioResponses;
  const AudioGenPage({super.key, required this.audioResponses});

  @override
  State<AudioGenPage> createState() => _AudioGenState();
}

class _AudioGenState extends State<AudioGenPage> {
  // TODO: add State variables
  List<AudioPlayer> audioPlayerList = [];
  List<Uint8List> audioBytesList = [];
  List<bool> _isPlayingList = [false,false, false];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAudioBytesList();

    late AudioPlayer player;
    for (var i=0;i<3;i++) {
      player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      player.setSource(BytesSource(audioBytesList[i]));
      audioPlayerList.add(player);
    }
  }

  void getAudioBytesList() {
    List<Uint8List> tmpList = [];
    for (var i=0;i<3;i++) {
      tmpList.add(widget.audioResponses[i].bodyBytes);
    }
    // sleep(const Duration(seconds: 30));
    setState(() {
      audioBytesList = tmpList;
    });
  }

  void togglePlayPause(int index) async {
    if (_isPlayingList[index]) {
      await audioPlayerList[index].pause();
    } else {
      await audioPlayerList[index].resume();
    }
    setState(() {
      _isPlayingList[index] = !_isPlayingList[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Selection"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8.0, right:8.0, top:10.0, bottom: 8.0),
              child: IconButton(
                iconSize: 48.0,
                onPressed: () {
                  togglePlayPause(0);
                },
                icon: Icon(_isPlayingList[0] ? Icons.pause : Icons.play_arrow)
              ),
            ),
            Text("Sample 1"),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right:8.0, top:8.0, bottom: 8.0),
              child: IconButton(
                iconSize: 48.0,
                onPressed: () {
                  togglePlayPause(1);
                }, 
                icon: Icon(_isPlayingList[1] ? Icons.pause : Icons.play_arrow)
              ),
            ),
            Text("Sample 2"),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right:8.0, top:8.0, bottom: 10.0),
              child: IconButton(
                iconSize: 48.0,
                onPressed: () {
                  togglePlayPause(2);
                }, 
                icon: Icon(_isPlayingList[2] ? Icons.pause : Icons.play_arrow)
              ),
            ),
            Text("Sample 3"),
          ],
        ),
        ),
      ),
    );
  }
}