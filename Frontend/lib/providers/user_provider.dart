import 'package:flutter/material.dart';

class MyUserInfo with ChangeNotifier {
  bool isLogin = false;
  String name = '';
  String nickname = '';
  String birth = '';
  String gender = '';
  String phone = '';
  String region = '';

  void changeIsLogin() {
    isLogin = !isLogin;
  }

  void setName(String name) {
    this.name = name;
  }

  void setNickname(String nickname) {
    this.nickname = nickname;
  }

  void setBirth(String birth) {
    this.birth = birth;
  }

  void setGender(String gender) {
    this.gender = gender;
  }

  void setPhone(String phone) {
    this.phone = phone;
  }

  void setRegion(String region) {
    this.region = region;
  }

  void setUser(Map<String, dynamic>? userDoc) {
    //파이어베이스 계정 불러온 다음 데이터를 전역변수에 대입
    setName(userDoc?["name"]);
    setNickname(userDoc?["nickname"]);
    setBirth(userDoc?["birth"]);
    setGender(userDoc?["gender"]);
    setPhone(userDoc?["phone"]);
    setRegion(userDoc?["region"]);
  }
}
