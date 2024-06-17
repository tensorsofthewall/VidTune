import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:googleapis/artifactregistry/v1.dart';
import 'dart:io';
import 'file.dart' show FileResource;
import 'package:http/http.dart' as http;
import 'package:test_app/util/constants.dart' as constants;

class VideoConstants {
  static final VideoConstants constants = VideoConstants._();

  factory VideoConstants() => constants; 
  VideoConstants._();

  dynamic convertToBase64(PlatformFile file) {
    final File fileForEncode = File(file.path??"");
    List<int> videoBytes = fileForEncode.readAsBytesSync();
    String base64Video = base64Encode(videoBytes);
    return {'mime_type': 'video/mp4','data': base64Video};
  }

  dynamic decodeBase64(String base64Encoding) {
    String decoded = utf8.decode(base64Url.decode(base64Encoding));
    return decoded;
  }
}




// Function for uploading media
Future<void> uploadMedia(PlatformFile file) async{

  final payload = jsonEncode({
    'contents': [
      {
        'parts': [
          {
            'inline_data': VideoConstants().convertToBase64(file),
          }
        ]
      }
    ]
  });
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
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': constants.apiKey,
    },
    body: payload,
  );

  print(response.statusCode);
}