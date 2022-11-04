import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiMessage {
  String api_url = "https://homelaone.kr/api/message";

  Future<Map<String, dynamic>> sendMessage(
      List<String> receivers, String message) async {
    final httpUri = Uri.parse(api_url);
    final response = await http.post(httpUri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"receivers": receivers, "message": message}));
    final result = json.decode(response.body);
    print(result);
    return result;
  }
}
