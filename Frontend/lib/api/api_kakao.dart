import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiKakao {
  String api_url = "https://dapi.kakao.com/v2/local";

  Future<Map<String, dynamic>> searchArea(
      String name, String lat, String lng) async {
    final httpUri = Uri.parse(api_url + "/search/keyword")
        .replace(queryParameters: {'query': name, 'y': lat, 'x': lng});
    await dotenv.load();
    final kakaoRestAPIKey = dotenv.get('kakaoRestAPIKey');
    final response = await http
        .get(httpUri, headers: {"Authorization": "KakaoAK ${kakaoRestAPIKey}"});
    final result = json.decode(response.body);
    return result;
  }

  Future<Map<String, dynamic>> searchAddr(String lat, String lng) async {
    final httpUri = Uri.parse(api_url + "/geo/coord2regioncode")
        .replace(queryParameters: {'y': lat, 'x': lng});
    await dotenv.load();
    final kakaoRestAPIKey = dotenv.get('kakaoRestAPIKey');
    final response = await http
        .get(httpUri, headers: {"Authorization": "KakaoAK ${kakaoRestAPIKey}"});
    final result = json.decode(response.body)["documents"][0];
    return result;
  }

  Future<String> searchRoadAddr(String lat, String lng) async {
    final httpUri = Uri.parse(api_url + "/geo/coord2address")
        .replace(queryParameters: {'y': lat, 'x': lng});
    await dotenv.load();
    final kakaoRestAPIKey = dotenv.get('kakaoRestAPIKey');
    final response = await http
        .get(httpUri, headers: {"Authorization": "KakaoAK ${kakaoRestAPIKey}"});
    final result =
        json.decode(response.body)["documents"][0]['address']['address_name'];
    return result;
  }
}
