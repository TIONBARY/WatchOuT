import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

DateTime? currentBackPressTime;

doubleClickPop() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(
        msg: "한 번 더 누르면 종료됩니다.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        fontSize: 12.5.sp,
        toastLength: Toast.LENGTH_SHORT);
    return false;
  }
  SystemNavigator.pop();
  return true;
}
