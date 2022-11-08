import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class HeartRateView extends StatefulWidget {
  const HeartRateView({
    Key? key,
    required this.margins,
    required this.provider,
  }) : super(key: key);
  final margins;
  final HeartRateProvider provider;

  @override
  State<HeartRateView> createState() => _HeartRateViewState();
}

class _HeartRateViewState extends State<HeartRateView> {
  @override
  void initState() {
    super.initState();
    // loadHeartRate();
  }

  void loadHeartRate() {
    getApplicationDocumentsDirectory().then((dir) =>
        File('${dir.path}/heartRate.txt')
            .readAsString()
            .then((value) => {docodeHeartRate(value)}));
  }

  void docodeHeartRate(String saved) {
    final data = jsonDecode(saved);
    widget.provider.heartRate = data['heartRate'];
    widget.provider.minValue = data['minValue'];
    widget.provider.maxValue = data['maxValue'];
  }

  void save() {
    Map<String, double> map = HashMap.fromEntries([
      MapEntry("heartRate", widget.provider.heartRate),
      MapEntry("minValue", widget.provider.minValue),
      MapEntry("maxValue", widget.provider.maxValue)
    ]);
    String saved = jsonEncode(map);
    print(saved);
    getApplicationDocumentsDirectory().then(
        (dir) => File('${dir.path}/heartRate.txt').writeAsStringSync(saved));
  }

  @override
  Widget build(BuildContext context) {
    SfRangeValues _values =
        SfRangeValues(widget.provider.minValue, widget.provider.maxValue);
    return Flexible(
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 0.h, 5.w, 0.h),
        margin: widget.margins,
        decoration: BoxDecoration(
            color: b25Color, borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "나의 심박수 범위 : ",
            ),
            // ${widget.provider.heartRate}
            SfRangeSlider(
              min: 40.0,
              max: 200.0,
              values: _values,
              activeColor: yColor,
              inactiveColor: y50Color,
              shouldAlwaysShowTooltip: true,
              showLabels: true,
              enableTooltip: true,
              tooltipTextFormatterCallback:
                  (dynamic actualValue, String formattedText) {
                return actualValue.toStringAsFixed(0);
              },
              minorTicksPerInterval: 1,
              onChanged: (SfRangeValues values) {
                setState(() {
                  _values = values;
                  widget.provider.changeMinValue(values.start);
                  widget.provider.changeMaxValue(values.end);
                  save();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
