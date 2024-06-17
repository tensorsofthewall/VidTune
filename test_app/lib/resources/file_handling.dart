import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'file.dart' show FileResource;
import 'package:http/http.dart' as http;
import 'package:test_app/util/constants.dart' as constants;

class FileConstants {
  static final FileConstants constants = FileConstants._();

  factory FileConstants() => constants; 
  FileConstants._();

  dynamic convertToBase64(PlatformFile file) {
    final File fileForEncode = File(file.path??"");
    List<int> videoBytes = fileForEncode.readAsBytesSync();
    String base64Video = base64Encode(videoBytes);
    print(file.name);
    return {'displayName': file.name,'mime_type': 'video/mp4','data': base64Video,};
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
        'file': FileConstants().convertToBase64(file),
      }
    ]
  });
  final response = await http.post(
    Uri.parse(constants.mediaFileUploadURL),
    headers: {
      'Content-Type': 'video/mp4',
      'X-Goog-Api-Key': constants.apiKey,
    },
    body: payload,
  );
  print(response.body);
}

void deleteMedia() async {
  var uploadedFiles = fetchAllMedia();
}

dynamic fetchAllMedia() async {
  final response = await http.get(
    Uri.parse(constants.mediaFileMetadataURL),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Goog-Api-Key': constants.apiKey,
    },
  );

  var uploadedFiles;

  if (response.statusCode == 200) {
    print("Success, pinged");
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    uploadedFiles = FileResource.fromJsonList(decoded['files']);
    for (final f in uploadedFiles) {
      print(f.displayName);
    }
  } else {
    print("Failed, Error ${response.statusCode}");
  }
  return uploadedFiles;
}


FileResource createFileMetadata(PlatformFile file) {
  return FileResource(name: "", displayName: file.name, mimeType: file.extension.toString());
}