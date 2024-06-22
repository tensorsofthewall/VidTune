import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test_app/util/constants.dart' as app_constants;



Future<http.Response> generate_music(List<String> prompts) async {
  final headers = {
    "Content-Type": "application/json"
  };
  final payload = jsonEncode({"prompts": prompts});

  print("Sending to musicgen");

  final response = await http.post(
    Uri.parse(app_constants.musicGenUrl),
    headers: headers,
    body: payload,
  );

  if (response.statusCode != 200) throw Exception('http.post error: statusCode= ${response.statusCode}');
  print("Done musicgen");

  return response;
}