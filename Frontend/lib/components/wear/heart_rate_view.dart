import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/constants.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

import '../../providers/heart_rate_provider.dart';

class HeartRateView extends StatefulWidget {
  const HeartRateView({Key? key, required this.margins, required this.texts})
      : super(key: key);
  final margins;
  final texts;

  @override
  State<HeartRateView> createState() => _HeartRateViewState();
}

class _HeartRateViewState extends State<HeartRateView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initHeartRate();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.fromLTRB(25.w, 5.h, 25.w, 5.h),
        margin: widget.margins,
        decoration: BoxDecoration(
            color: n25Color, borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("현재 심박수: " + widget.texts.toString()),
          ],
        ),
      ),
    );
  }
}

void initHeartRate() {
  final watch = WatchConnectivity();
  var reachable = false;
  watch.isReachable.then((value) => reachable = value);

  if (reachable) {
    watch.messageStream.listen((e) => debugPrint(e.toString()));
    watch.contextStream.listen((e) => updateHeartRate(e.values.last));
  }
}

// 워치 접근 가능하고, 심박수 갱신시 실행
void updateHeartRate(value) {
  debugPrint(value + " 심박수");
  HeartRateProvider().heartRate = double.parse(value);
}
