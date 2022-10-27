import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/constants.dart';

class SetPageRadioButton extends StatelessWidget {
  const SetPageRadioButton({
    Key? key,
    required this.margins,
    required this.texts,
    required this.values,
    required this.onchangeds,
  }) : super(key: key);
  final margins;
  final texts;
  final values;
  final onchangeds;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.fromLTRB(25.w, 5.h, 25.w, 5.h),
        margin: margins,
        decoration: BoxDecoration(
            color: n25Color, borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(texts),
            Switch(value: values, onChanged: onchangeds),
          ],
        ),
      ),
    );
  }
}
