import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class HeartRateView extends StatefulWidget {
  const HeartRateView(
      {Key? key, required this.margins, required this.heartRate})
      : super(key: key);
  final margins;
  final heartRate;

  @override
  State<HeartRateView> createState() => _HeartRateViewState();
}

class _HeartRateViewState extends State<HeartRateView> {
  @override
  void initState() {
    super.initState();
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
            Text("현재 심박수: ${widget.heartRate}"),
          ],
        ),
      ),
    );
  }
}
