// Methods for handling MusicGen calls (hosted on zeroTier as of v0.1.0)
import 'dart:async';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:http/http.dart' as http;
import 'package:vibematch/assets/constants.dart' as app_constants;
import 'package:vibematch/functions/file_handling.dart' show uploadMedia;
import 'package:firebase_storage/firebase_storage.dart' show Reference;
import 'package:path/path.dart' as path;
// import 'package:zerotier_sockets/zerotier_sockets.dart';
// import 'package:path_provider/path_provider.dart';



Future<http.Response> generateMusic(List<String> prompts, int duration) async {
  final headers = {
    "Content-Type": "application/json"
  };
  final payload = jsonEncode({"prompts": prompts, "duration": duration});

  // print("Sending to musicgen");

  final response = http.post(
    Uri.parse(app_constants.musicGenUrl),
    headers: headers,
    body: payload,
  );

  // if (response.statusCode != 200) throw Exception('http.post error: statusCode= ${response.statusCode}');
  // print("Done musicgen");

  return response;
}


// Future<void> startNodeAndConnectToNetwork(String networkId) async {
//   // Obtain node instance
//   var node = ZeroTierNode.instance;

//   // Set persistent storage path to have identity and network configuration cached
//   var appDocPath = (await getApplicationDocumentsDirectory()).path + '/zerotier_node';
//   node.initSetPath(appDocPath);

//   // Try to start the node
//   var result = node.start();
//   if (!result.success) {
//     throw Exception('Failed to start node: ${result.errorMessage}');
//   }

//   await node.waitForOnline();

//   // Parse network id from hex string
//   var nwId = BigInt.parse(networkId, radix: 16);

//   // Join network
//   result = node.join(nwId);
//   if (!result.success) {
//     throw Exception('Failed to join network: ${result.errorMessage}');
//   }

//   await node.waitForNetworkReady(nwId);
//   await node.waitForAddressAssignment(nwId);

//   // Get network info
//   var networkInfo = node.getNetworkInfo(nwId);
//   print(networkInfo?.name);
//   print(networkInfo?.address);
//   print(networkInfo?.id);
// }

// Future<http.Response> generateMusicZT(List<String> prompts, int duration) async {
//   final headers = {"Content-Type": "application/json"};
//   final payload = jsonEncode({"prompts": prompts, "duration": duration});

//   await startNodeAndConnectToNetwork('60ee7c034a56bbdd'); // Replace with your ZeroTier network ID

//   ZeroTierSocket socket;
//   try {
//     // Replace 'your-server-ip' with the IP address of your server on the ZeroTier network
//     socket = await ZeroTierSocket.connect('10.147.17.252', 8000); // Assuming your server is running on port 80
//   } catch (e) {
//     print('Failed to connect socket: $e');
//     rethrow;
//   }

//   final request = 'POST ${app_constants.musicGenUrl} HTTP/1.1\r\n'
//                   'Content-Type: application/json\r\n'
//                   'Content-Length: ${payload.length}\r\n'
//                   '\r\n'
//                   '$payload';

//   socket.sink.add(Uint8List.fromList(request.codeUnits));

//   final responseCompleter = Completer<Uint8List>();
//   final responseData = <int>[];

//   socket.stream.listen((data) {
//     responseData.addAll(data);
//     if (responseData.length >= data.length) {
//       responseCompleter.complete(Uint8List.fromList(responseData));
//     }
//   });

//   final responseBytes = await responseCompleter.future;
//   final responseString = utf8.decode(responseBytes);

//   // Close the ZeroTier socket connection
//   await socket.close();

//   // Parse the HTTP response
//   final response = http.Response(
//     responseString,
//     200,
//     headers: headers,
//     request: null, // Provide the original request if needed
//   );

//   print("Done musicgen");

//   return response;
// }


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