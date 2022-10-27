import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/components/main/main_page_text_button.dart';
import 'package:homealone/constants.dart';

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
            margins: EdgeInsets.fromLTRB(10.w, 5.h, 5.w, 5.h),
            boxcolors: Colors.red,
            onpresseds: () {},
            texts: 'SOS',
            textcolors: Colors.white,
            fontsizes: 50.sp),
        Flexible(
            child: Column(
          children: [
            MainPageTextButton(
                flexs: 1,
                margins: EdgeInsets.fromLTRB(5.w, 10.h, 10.w, 5.h),
                boxcolors: Colors.black12,
                onpresseds: () {},
                texts: '',
                textcolors: nColor,
                fontsizes: 15.sp),
            MainPageTextButton(
                flexs: 1,
                margins: EdgeInsets.fromLTRB(5.w, 5.h, 10.w, 10.h),
                boxcolors: Colors.black12,
                onpresseds: () {},
                texts: '',
                textcolors: nColor,
                fontsizes: 15.sp)
          ],
        ))
      ],
    );
  }
}
