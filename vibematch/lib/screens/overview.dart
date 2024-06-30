import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'homepage.dart';
import 'package:flutter/foundation.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overview"),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () {
                if (kDebugMode) {
                  developer.log("Goes to prompt screen");
                }
              },
              child: const Text("Custom Music Prompt"),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const HomePage();
                }));
                if (kDebugMode) {
                  developer.log("Goes to home screen");
                }
              },
              child: const Text("Video-to-Audio"),
            ),
          ),
        ],
      ),
    );
  }
}
