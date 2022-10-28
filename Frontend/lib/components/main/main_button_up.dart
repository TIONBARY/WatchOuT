import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/main/main_page_text_button.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class MainButtonUp extends StatefulWidget {
  const MainButtonUp({Key? key}) : super(key: key);

  @override
  State<MainButtonUp> createState() => _MainButtonUpState();
}

class _MainButtonUpState extends State<MainButtonUp> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MainPageTextButton(
            flexs: 2,
            margins: EdgeInsets.fromLTRB(2.w, 1.h, 1.w, 1.h),
            boxcolors: Colors.red,
            onpresseds: () {},
            texts: 'SOS',
            textcolors: Colors.white,
            fontsizes: 40.sp),
        Flexible(
            child: Column(
          children: [
            MainPageTextButton(
                flexs: 1,
                margins: EdgeInsets.fromLTRB(1.w, 1.h, 2.w, 0.5.h),
                boxcolors: Colors.black12,
                onpresseds: () {},
                texts: '미정',
                textcolors: nColor,
                fontsizes: 12.5.sp),
            MainPageTextButton(
                flexs: 1,
                margins: EdgeInsets.fromLTRB(1.w, 0.5.h, 2.w, 1.h),
                boxcolors: Colors.black12,
                onpresseds: () {},
                texts: '미정',
                textcolors: nColor,
                fontsizes: 12.5.sp)
          ],
        ))
      ],
    );
  }
}
