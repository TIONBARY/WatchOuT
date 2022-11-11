import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/call_dialog.dart';
import 'package:homealone/components/main/main_page_animated_button.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
    String sidoName = splitedAddress[1];
    String guName = splitedAddress[2];
    String? phones = guCall[guName];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 3,
            child: Container(
              child: AnimatedButton(
                height: 17.5.h,
                blurRadius: 7.5,
                isOutline: true,
                type: PredefinedThemes.light,
                onTap: () {},
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          'C\nA\nM',
                          style: TextStyle(fontSize: 17.5.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        child: Image.asset(
                          "assets/icons/shadowcctvreverse.png",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MainPageAniBtn(
                  margins: EdgeInsets.only(bottom: 4),
                  types: PredefinedThemes.warning,
                  ontaps: () {
                    (sidoName == '서울')
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Future.delayed(Duration(seconds: 3), () {
                              //   UrlLauncher.launchUrl(Uri.parse("tel:" + phones));
                              // });
                              return CallDialog(
                                  null,
                                  guName + '청 스카우트 상황실',
                                  phones!,
                                  '※ 주말 및 공휴일 제외 \n월 : 22 ~ 24시, 화 ~ 금 : 22 ~ 01시',
                                  null);
                            },
                          )
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BasicDialog(
                                  EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                                  12.5.h,
                                  '안심귀가 서비스는 \'서울\' 에서만 제공됩니다.',
                                  null);
                            },
                          );
                  },
                  texts: '안심귀가\n서비스',
                ),
                MainPageAniBtn(
                  margins: EdgeInsets.only(top: 4),
                  types: PredefinedThemes.warning,
                  ontaps: () async {
                    await launch('https://m.sexoffender.go.kr/main.nsc',
                        forceWebView: false, forceSafariVC: false);
                  },
                  texts: '성범죄자\n알림e',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
