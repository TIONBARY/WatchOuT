import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:slide_countdown/slide_countdown.dart';

class SOSDialog extends StatelessWidget {
  SOSDialog({super.key});

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
                  Text(
                    '긴급 상황을 전파합니다.',
                    style: TextStyle(fontFamily: 'HanSan'),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                    child: SlideCountdown(
                      duration: const Duration(seconds: 5),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset("assets/icons/shadowsiren.png", height: 7.5.h),
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
                style: TextStyle(color: bColor, fontFamily: 'HanSan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
