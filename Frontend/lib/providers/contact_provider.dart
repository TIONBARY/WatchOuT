import 'package:flutter/material.dart';

class ContactInfo with ChangeNotifier {
  Map<String, String> responderMap = {};

  void addResponder(String name, String number) {
    responderMap.addAll({
      name: number,
    });
  }

  void addAllResponder(Map<String, String> datas) {
    responderMap.addAll(datas);
  }

  Map<String, String> getResponder() {
    return responderMap;
  }

  String? getNumber(String name) {
    return responderMap[name];
  }
}
