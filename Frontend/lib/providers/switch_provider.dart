import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchBools with ChangeNotifier {
  bool useWearOS = true;
  bool useScreen = true;
  bool useGPS = true;
  bool useSiren = true;
  bool useDzone = true;
  var pref;

  onCreate() async {
    pref = await SharedPreferences.getInstance();
    load();
  }

  save() {
    if (pref == null) {
      return;
    }
    pref.setBool("useWearOS", useWearOS);
    pref.setBool("useScreen", useScreen);
    pref.setBool("useGPS", useGPS);
    pref.setBool("useSiren", useSiren);
    pref.setBool("useDzone", useDzone);
  }

  void load() {
    if (pref == null) {
      return;
    }
    if (pref.getKeys().isEmpty) {
      return;
    }
    useWearOS = pref.getBool("useWearOS")!;
    useScreen = pref.getBool("useScreen")!;
    useGPS = pref.getBool("useGPS")!;
    useSiren = pref.getBool("useSiren")!;
    useDzone = pref.getBool("useDzone")!;
  }

  void changeWearOS() {
    useWearOS = !useWearOS;
    save();
  }

  void changeScreen() {
    useScreen = !useScreen;
    save();
  }

  void changeGPS() {
    useGPS = !useGPS;
    save();
  }

  void changeSiren() {
    useSiren = !useSiren;
    save();
  }

  void changeDzone() {
    useDzone = !useDzone;
    save();
  }
}
