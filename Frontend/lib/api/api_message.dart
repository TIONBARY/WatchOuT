import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiMessage {
  String api_url = "https://homelaone.kr/api/message";

  Future<Map<String, dynamic>> sendMessage(
      List<String> receivers, String message) async {
    final httpUri = Uri.parse(api_url);
    final response = await http.post(httpUri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"receivers": receivers, "message": message}));
    final result = json.decode(response.body);
    return result;
  }

  Future<Map<String, dynamic>> sendMMSMessage(
      XFile file, List<String> receivers, String message) async {
    final httpUri = Uri.parse(api_url + "/mms");
    var request = http.MultipartRequest('POST', httpUri);
    if (file != null) {
      final httpImage = await http.MultipartFile.fromPath('files', file.path);
      request.files.add(httpImage);
    }
    request.files.add(http.MultipartFile.fromBytes(
      'message',
      utf8.encode(json.encode({"receivers": receivers, "message": message})),
      contentType: MediaType(
        'application',
        'json',
        {'charset': 'utf-8'},
      ),
    ));
    var response = await request.send();
    http.Response httpResponse = await http.Response.fromStream(response);
    String body = httpResponse.body;
    final result = json.decode(body);
    return result;
  }
}
