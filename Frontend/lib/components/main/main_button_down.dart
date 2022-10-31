import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/main/main_page_text_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

Map guCall = {
  '강남구': '02-3423-6000',
  '강동구': '02-3425-5009',
  '강북구': '02-901-6112',
  '강서구': '02-2600-1281',
  '관악구': '02-879-7640',
  '광진구': '02-450-1330',
  '구로구': '02-860-2525',
  '금천구': '02-2627-2414',
  '도봉구': '02-2091-3109',
  '동작구': '02-820-1040',
  '서대문구': '02-330-1119',
  '성동구': '02-2286-6262',
  '송파구': '02-2147-2799',
  '영등포구': '02-831-9736',
  '은평구': '02-351-8000',
  '중구': '02-3396-4000',
  '노원구': '02-2116-3742',
  '동대문구': '02-2127-4626',
  '마포구': '02-3153-8104',
  '서초구': '02-2155-8510',
  '성북구': '02-2241-1900',
  '양천구': '02-2620-3399',
  '용산구': '02-2199-6300',
  '종로구': '02-2148-1111',
  '중랑구': '02-2094-1148',
};

class MainButtonDown extends StatefulWidget {
  @override
  State<MainButtonDown> createState() => _MainButtonDownState();
}

class _MainButtonDownState extends State<MainButtonDown> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String address = Provider.of<MyUserInfo>(context, listen: false).region;
    final splitedAddress = address.split(' ');
    String guName = splitedAddress[1];
    String phones =
        splitedAddress[1] == null ? splitedAddress[2] : splitedAddress[1];

    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              MainPageTextButton(
                  flexs: 1,
                  margins: EdgeInsets.fromLTRB(2.w, 1.h, 1.w, 0.5.h),
                  boxcolors: Colors.black12,
                  onpresseds: () {
                    UrlLauncher.launchUrl(Uri.parse("tel: " + phones));
                  },
                  texts: '안심귀가\n서비스',
                  textcolors: nColor,
                  fontsizes: 12.5.sp),
              MainPageTextButton(
                  flexs: 1,
                  margins: EdgeInsets.fromLTRB(2.w, 0.5.h, 1.w, 1.h),
                  boxcolors: Colors.black12,
                  onpresseds: () async {
                    await launch('https://m.sexoffender.go.kr/main.nsc',
                        forceWebView: false, forceSafariVC: false);
                  },
                  texts: '성범죄자\n알림e',
                  textcolors: nColor,
                  fontsizes: 12.5.sp),
            ],
          ),
        ),
        MainPageTextButton(
            flexs: 2,
            margins: EdgeInsets.fromLTRB(1.w, 1.h, 2.w, 1.h),
            boxcolors: nColor,
            onpresseds: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SafeAreaCCTVMapPage()));
            },
            texts: '',
            textcolors: Colors.white,
            fontsizes: 40.sp),
      ],
    );
  }
}
