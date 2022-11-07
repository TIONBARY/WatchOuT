import 'package:flutter/material.dart';

class HeartRateProvider with ChangeNotifier {
  double heartRate = 0.0;
  double minValue = 60.0;
  double maxValue = 120.0;
  double gapValue = 0.0;
  bool isEmergency = false;

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
    notifyListeners();
  }

  void changeMinValue(value) {
    minValue = value;
    notifyListeners();
  }

  void changeMaxValue(value) {
    maxValue = value;
    notifyListeners();
  }

  void changeGapValue(value) {
    gapValue = value;
    notifyListeners();
  }

  void changeIsEmergency(value) {
    isEmergency = value;
    notifyListeners();
  }
}
