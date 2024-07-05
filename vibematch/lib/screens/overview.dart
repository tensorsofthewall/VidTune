import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'homepage.dart';
import 'package:flutter/foundation.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  // late PermissionStatus storageStatus;

  // Future<void> _requestPermissions() async {
  //   PermissionStatus status;
  //   developer.log("Requesting permission");
  //   status = await Permission.photos.request();
  //   developer.log("Permission granted: ${status.isGranted}");
  //   if (!status.isGranted) {
  //     _showPermissionDeniedDialog();
  //   }
  //   setState(() {
  //     storageStatus = status;
  //   });
  // }

  // void _showPermissionDeniedDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Permissions Required'),
  //       content: const Text("This app needs storage permissions"),
  //       actions: [
  //         TextButton(onPressed: () => openAppSettings(), child: const Text("Ok"))
  //       ],
  //     )
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overview"),
      ),
      body: Row(
        children: <Widget>[
          // Expanded(
          //   child: TextButton(
          //     onPressed: () {
          //       if (kDebugMode) {
          //         developer.log("Goes to prompt screen");
          //       }
          //     },
          //     child: const Text("Custom Music Prompt"),
          //   ),
          // ),
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
