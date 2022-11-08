import 'package:flutter/material.dart';

class MyUserInfo with ChangeNotifier {
  bool isCheck = false;
  String name = '';
  String nickname = '';
  String birth = '';
  String gender = '';
  String phone = '';
  String region = '';
  String profileImage = '';
  String latitude = '';
  String longitude = '';

  void confirmCheck() {
    isCheck = true;
  }

  void initCheck() {
    isCheck = false;
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

  void setProfileImage(String profileImage) {
    this.profileImage = profileImage;
  }

  void setLatitude(String latitude) {
    this.latitude = latitude;
  }

  void setLongitude(String longitude) {
    this.longitude = longitude;
  }


  void setUser(Map<String, dynamic>? userDoc) {
    //파이어베이스 계정 불러온 다음 데이터를 전역변수에 대입
    setName(userDoc?["name"]);
    setNickname(userDoc?["nickname"]);
    setBirth(userDoc?["birth"]);
    setGender(userDoc?["gender"]);
    setPhone(userDoc?["phone"]);
    setRegion(userDoc?["region"]);
    setProfileImage(userDoc?["profileImage"]);
    setLatitude(userDoc?["latitude"]);
    setLongitude(userDoc?["longitude"]);
  }
}
