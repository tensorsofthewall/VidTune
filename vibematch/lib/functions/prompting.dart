// Methods for handling MusicGen calls (hosted on zeroTier as of v0.1.0)
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:http/http.dart' as http;
import 'package:vibematch/assets/constants.dart' as app_constants;
import 'package:vibematch/functions/file_handling.dart' show uploadMedia;
import 'package:firebase_storage/firebase_storage.dart' show Reference;
import 'package:path/path.dart' as path;



Future<http.Response> generateMusic(List<String> prompts) async {
  final headers = {
    "Content-Type": "application/json"
  };
  final payload = jsonEncode({"prompts": prompts});

  // print("Sending to musicgen");

  final response = await http.post(
    Uri.parse(app_constants.musicGenUrl),
    headers: headers,
    body: payload,
  );

  if (response.statusCode != 200) throw Exception('http.post error: statusCode= ${response.statusCode}');
  // print("Done musicgen");

  return response;
}


Future<Map<String, dynamic>> promptMLLM(String filePath, Reference storage) async {
  final Uint8List fileBytes = await File(filePath).readAsBytes();

  late dynamic fileParts;

  if (fileBytes.lengthInBytes >= app_constants.maxFileSizeInBytes) {
    fileParts = await uploadMedia(filePath, storage);
  } else {
    fileParts = DataPart(app_constants.extension2MimeType[path.extension(filePath).split(".").last].toString(), fileBytes);
  }

  // Initialize MLLM
  final GenerativeModel mllmModel = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-flash',
    systemInstruction:  Content.system(app_constants.systemInstructions),
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  // Query MLLM and get response
  final mllmResponse = await mllmModel.generateContent([
    Content.multi([
      TextPart(app_constants.mllmPrompt),
      fileParts,
    ])
  ]);

  // Return JSON-formatted response
  return jsonDecode(mllmResponse.text.toString()) as Map<String, dynamic>;
}