import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibematch/util/constants.dart' as app_constants;



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