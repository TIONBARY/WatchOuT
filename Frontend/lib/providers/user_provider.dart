import 'package:flutter/material.dart';

class UserInfo with ChangeNotifier {
  bool isLogin = false;
  String name = '';
  String nickname = '';
  int age = 0;
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

  void setAge(int age) {
    this.age = age;
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

  // void setUser(firebasedb db){ //파이어베이스 계정 불러온 다음 데이터를 전역변수에 대입
  //   setName(db.name);
  //   setNickname();
  //   setAge();
  //   setGender();
  //   setPhone();
  //   setRegion();
  // }
}
