import 'package:flutter/material.dart';

class UserInfo with ChangeNotifier {
  bool isLogin = false;

  void changeIsLogin() {
    isLogin = !isLogin;
  }
}
