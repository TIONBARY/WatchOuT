import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeartRateProvider with ChangeNotifier {
  double heartRate = 0.0;
  double minValue = 60.0;
  double maxValue = 120.0;
  double gapValue = 0.0;
  bool isEmergency = false;
  var pref;

  onCreate() async {
    pref = await SharedPreferences.getInstance();
    load();
  }

  void load() {
    if (pref == null) {
      return;
    }
    if (pref.getKeys().isEmpty) {
      return;
    }
    heartRate = pref.getDouble("heartRate")!;
    minValue = pref.getDouble("minValue")!;
    maxValue = pref.getDouble("maxValue")!;
    gapValue = pref.getDouble("gapValue")!;
  }

  save() {
    if (pref == null) {
      return;
    }
    pref.setDouble("heartRate", heartRate);
    pref.setDouble("minValue", minValue);
    pref.setDouble("maxValue", maxValue);
    pref.setDouble("gapValue", gapValue);
  }

  void changeHeartRate(value) {
    heartRate = value;
    if (heartRate < (minValue - gapValue) ||
        heartRate >= (maxValue + gapValue)) {
      debugPrint("이상 상황 $heartRate");
      isEmergency = true;
    } else {
      debugPrint("정상범위 심박수 $heartRate");
      isEmergency = false;
    }
    save();
  }

  void changeMinValue(value) {
    minValue = value;
    save();
  }

  void changeMaxValue(value) {
    maxValue = value;
    save();
  }

  void changeGapValue(value) {
    gapValue = value;
    save();
  }

  void changeIsEmergency(value) {
    isEmergency = value;
    save();
  }
}
