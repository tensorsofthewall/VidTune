import 'dart:convert';

import 'package:googleapis/artifactregistry/v1.dart';
import 'dart:io';
import 'file.dart' show FileResource;
import 'package:http/http.dart' as http;
import 'package:test_app/util/constants.dart' as constants;

class VideoConstants {
  static final VideoConstants constants = VideoConstants._();

  factory VideoConstants() => constants; 
  VideoConstants._();

  dynamic convertToBase64(File file) {
    List<int> videoBytes = file.readAsBytesSync();
    String base64Video = base64Encode(videoBytes);
    return {'mime_type': 'video/mp4','data': base64Video};
  }

  dynamic decodeBase64(String base64Encoding) {
    String decoded = utf8.decode(base64Url.decode(base64Encoding));
    return decoded;
  }
}




// Function for uploading media
Future<void> uploadMedia(File file) async{

  final Map<String, dynamic> payload = {
    'contents': [
      {
        'parts': [
          {
            'inline_data': VideoConstants().convertToBase64(file),
          }
        ]
      }
    ]
  };
//   '{"contents":[
//     {
//       "parts":[
//         {"text": "What is this picture?"},
//         {
//           "inline_data": {
//             "mime_type":"image/jpeg",
//             "data": "'$(base64 -w0 image.jpg)'"
//           }
//         }
//       ]
//     }
//   ]
// }';
  final response = await http.post(
    Uri.parse('https://generativelanguage.googleapis.com/upload/v1beta/files'),
    headers: {
      'Content-Type': 'video/mp4',
      'X-Goog-Api-Key': constants.apiKey,
    },
    body: payload,
  );
}