import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class PackageNotFoundDialog extends StatelessWidget {
  PackageNotFoundDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment:
          AlignmentGeometry.lerp(Alignment.center, Alignment.center, 18.h),
      insetPadding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(8.h)),
        ),
        child: RichText(
          text: TextSpan(
              text: "해당 기능을 지원하지 않는 기종입니다!",
              style: TextStyle(
                color: bColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
    );
  }
}
