import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/main/main_page_text_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class MainButtonDown extends StatefulWidget {
  const MainButtonDown({Key? key}) : super(key: key);

  @override
  State<MainButtonDown> createState() => _MainButtonDownState();
}

class _MainButtonDownState extends State<MainButtonDown> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              MainPageTextButton(
                  flexs: 1,
                  margins: EdgeInsets.fromLTRB(1.w, 1.h, 0.5.w, 0.5.h),
                  boxcolors: Colors.black12,
                  onpresseds: () {},
                  texts: '안심귀가\n서비스',
                  textcolors: nColor,
                  fontsizes: 15.sp),
              MainPageTextButton(
                  flexs: 1,
                  margins: EdgeInsets.fromLTRB(10.w, 5.h, 5.w, 10.h),
                  boxcolors: Colors.black12,
                  onpresseds: () async {
                    await launch('https://m.sexoffender.go.kr/main.nsc',
                        forceWebView: false, forceSafariVC: false);
                  },
                  texts: '성범죄자\n알림e',
                  textcolors: nColor,
                  fontsizes: 15.sp),
            ],
          ),
        ),
        MainPageTextButton(
            flexs: 2,
            margins: EdgeInsets.fromLTRB(5.w, 5.h, 10.w, 5.h),
            boxcolors: nColor,
            onpresseds: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SafeAreaCCTVMapPage()));
            },
            texts: '',
            textcolors: Colors.white,
            fontsizes: 50.sp),
      ],
    );
  }
}
