import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const locationCheck = "locationCheck";
const fetchBackground = "fetchBackground";

class SwitchBools with ChangeNotifier {
  bool useWearOS = true;
  bool useScreen = true;
  bool useGPS = true;
  bool useSiren = true;
  bool useDzone = true;
  late SharedPreferences pref;
  Set<String> keys = {
    "useWearOS",
    "useScreen",
    "useGPS",
    "useSiren",
    "useDzone",
  };

  onCreate() async {
    pref = await SharedPreferences.getInstance();
    load();
  }

  save() {
    pref.setBool("useWearOS", useWearOS);
    pref.setBool("useScreen", useScreen);
    pref.setBool("useGPS", useGPS);
    pref.setBool("useSiren", useSiren);
    pref.setBool("useDzone", useDzone);
  }

  void load() {
    if (pref.getKeys().isEmpty) {
      save();
      return;
    }
    for (var key in keys) {
      if (pref.getBool(key) == null) {
        pref.setBool(key, true);
      }
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
    if (useScreen) {
      Workmanager().registerPeriodicTask(locationCheck, fetchBackground,
          frequency: Duration(minutes: 15),
          constraints: Constraints(
              networkType: NetworkType.not_required, requiresDeviceIdle: true));
    } else {
      Workmanager().cancelByUniqueName(locationCheck);
    }
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
