import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:slide_countdown/slide_countdown.dart';

class SOSDialog extends StatelessWidget {
  SOSDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
        height: 25.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: Column(
                children: [
                  SlideCountdown(
                    duration: const Duration(seconds: 5),
                  ),
                  Text("\n긴급 상황을 전파합니다."),
                ],
              ),
            ),
            Image.asset("assets/siren.png", height: 6.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: b25Color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(color: bColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
