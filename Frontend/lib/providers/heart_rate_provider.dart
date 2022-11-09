import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeartRateProvider with ChangeNotifier {
  double heartRate = 0.0;
  double minValue = 60.0;
  double maxValue = 120.0;
  double gapValue = 0.0;
  late SharedPreferences pref;
  Set<String> keys = {
    "heartRate",
    "minValue",
    "maxValue",
    "gapValue",
  };

  onCreate() async {
    pref = await SharedPreferences.getInstance();
    load();
  }

  void load() {
    if (pref.getKeys().isEmpty) {
      return;
    }
    for (var key in keys) {
      if (pref.getDouble(key) == null) {
        return;
      }
    }
    heartRate = pref.getDouble("heartRate")!;
    minValue = pref.getDouble("minValue")!;
    maxValue = pref.getDouble("maxValue")!;
    gapValue = pref.getDouble("gapValue")!;
  }

  save() {
    pref.setDouble("heartRate", heartRate);
    pref.setDouble("minValue", minValue);
    pref.setDouble("maxValue", maxValue);
    pref.setDouble("gapValue", gapValue);
  }

  void changeHeartRate(value) {
    heartRate = value;
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
}
