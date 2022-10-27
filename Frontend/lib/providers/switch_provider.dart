import 'package:flutter/material.dart';

class SwitchBools with ChangeNotifier{
  bool useWearOS = true;
  bool useScreen = true;
  bool useGPS = true;
  bool useSiren = true;
  bool useDzone = true;

  void changeWearOS() {
    useWearOS = !useWearOS;
  }
  void changeScreen() {
    useScreen = !useScreen;
  }
  void changeGPS() {
    useGPS = !useGPS;
  }
  void changeSiren() {
    useSiren = !useSiren;
  }
  void changeDzone() {
    useDzone = !useDzone;
  }
}
