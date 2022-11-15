import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:homealone/components/main/main_page_animated_button.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class MainGuide extends StatefulWidget {
  const MainGuide({Key? key}) : super(key: key);

  @override
  State<MainGuide> createState() => _MainGuideState();
}

class _MainGuideState extends State<MainGuide> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'WatchOuT',
            style:
                TextStyle(color: yColor, fontSize: 20.sp, fontFamily: 'HanSan'),
          ),
          backgroundColor: bColor,
          actions: [
            Container(
              padding: EdgeInsets.fromLTRB(1.w, 1.h, 1.w, 1.h),
              child: IntroStepBuilder(
                order: 1,
                // text: '클릭시 개인 정보 수정 화면',
                text: Text(
                  '회원 정보 수정 및 탈퇴',
                ).data,
                padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                onWidgetLoad: () {
                  Intro.of(context).start();
                },
                builder: (context, key) => CircleAvatar(
                    backgroundImage: AssetImage('assets/icons/shadowsiren.png'),
                    key: key),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                height: kToolbarHeight - 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: Row(
                  children: [
                    IntroStepBuilder(
                      order: 2,
                      text: '메인화면',
                      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                      builder: (context, key) => Expanded(
                        key: key,
                        flex: 1,
                        child: Container(
                          height: kToolbarHeight - 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: bColor,
                          ),
                          child: Center(
                            child: Text(
                              '홈',
                              style: TextStyle(
                                color: yColor,
                                fontFamily: 'HanSan',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IntroStepBuilder(
                      order: 3,
                      text:
                          '지도에서 주변 안전 인프라 탐색과\nCCTV 정보가 확인 가능하며,\n보호자에게 실시간으로\n나의 귀갓길을 공유할 수 있음',
                      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                      builder: (context, key) => Expanded(
                        key: key,
                        flex: 1,
                        child: Container(
                          height: kToolbarHeight - 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: Text(
                              '안전 지도',
                              style: TextStyle(
                                color: bColor,
                                fontFamily: 'HanSan',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IntroStepBuilder(
                      order: 4,
                      text: '안전 지도에서 공유받은 코드로\n피보호자의 실시간 귀갓길 확인 ',
                      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                      builder: (context, key) => Expanded(
                        key: key,
                        flex: 1,
                        child: Container(
                          height: kToolbarHeight - 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: Text(
                              '귀가 공유',
                              style: TextStyle(
                                color: bColor,
                                fontFamily: 'HanSan',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IntroStepBuilder(
                      order: 5,
                      text: '스마트워치와 앱 설정,\n비상연락처 등록',
                      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                      builder: (context, key) => Expanded(
                        key: key,
                        flex: 1,
                        child: Container(
                          height: kToolbarHeight - 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: Text(
                              '설정',
                              style: TextStyle(
                                color: bColor,
                                fontFamily: 'HanSan',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      child: Text(
                        '가이드 보러가기',
                        style: TextStyle(
                          fontFamily: 'HanSan',
                        ),
                      ),
                    ),
                    IntroStepBuilder(
                      order: 6,
                      text: '가이드 화면',
                      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                      builder: (context, key) => ElevatedButton(
                        key: key,
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          shape: CircleBorder(),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.all(2),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: bColor,
                        ),
                        child: Icon(Icons.question_mark, color: yColor),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IntroStepBuilder(
                  order: 7,
                  text: '안전 교육 영상',
                  padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                  builder: (context, key) => ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                    key: key,
                    child: Image.asset(
                      'assets/guidesample.jpg',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 3,
                        child: IntroStepBuilder(
                          order: 8,
                          text: '나의 캠과 상대방의 캠을\n공유받은 코드로 연결하여\n필요시 확인',
                          padding:
                              EdgeInsets.fromLTRB(-2.w, -2.25.h, -2.w, -2.25.h),
                          builder: (context, key) => AnimatedButton(
                            key: key,
                            height: 17.5.h,
                            width: 50.w,
                            blurRadius: 7.5,
                            isOutline: true,
                            type: PredefinedThemes.light,
                            onTap: () {},
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'C\nA\nM',
                                    style: TextStyle(
                                        fontSize: 17.5.sp,
                                        fontFamily: 'HanSan'),
                                    textAlign: TextAlign.center,
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
                            IntroStepBuilder(
                              order: 9,
                              text: '성범죄자 알림e\n서비스로 이동',
                              padding:
                                  EdgeInsets.fromLTRB(-2.5.w, 2, -2.5.w, 2),
                              builder: (context, key) => AnimatedButton(
                                key: key,
                                width: 30.w,
                                blurRadius: 7.5,
                                isOutline: true,
                                type: null,
                                color: nColor,
                                onTap: () async {},
                                child: Text(
                                  '성범죄자\n알림e',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'HanSan',
                                  ),
                                ),
                              ),
                            ),
                            IntroStepBuilder(
                              order: 10,
                              text: '본인 주소지에 맞는\n구청 번호로 연결',
                              padding:
                                  EdgeInsets.fromLTRB(-2.5.w, 2, -2.5.w, -1),
                              builder: (context, key) => MainPageAniBtn(
                                key: key,
                                margins: EdgeInsets.only(bottom: 4),
                                types: PredefinedThemes.primary,
                                ontaps: () {},
                                texts: '안심귀가\n서비스',
                                colors: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IntroStepBuilder(
                              order: 11,
                              text: '목격한 현장을\n촬영하면\n바로 112에 신고 문자 발송',
                              padding:
                                  EdgeInsets.fromLTRB(-2.5.w, 2, -2.5.w, -1),
                              builder: (context, key) => MainPageAniBtn(
                                key: key,
                                margins: EdgeInsets.only(bottom: 4),
                                types: PredefinedThemes.warning,
                                ontaps: () {},
                                texts: '신고',
                                colors: bColor,
                              ),
                            ),
                            IntroStepBuilder(
                              order: 12,
                              text: '여러 위기상황에 대한\n대처 매뉴얼',
                              padding:
                                  EdgeInsets.fromLTRB(-2.5.w, -1, -2.5.w, 2),
                              builder: (context, key) => MainPageAniBtn(
                                key: key,
                                margins: EdgeInsets.only(top: 4),
                                types: PredefinedThemes.warning,
                                ontaps: () {},
                                texts: '위기상황 \n대처메뉴얼',
                                colors: bColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: IntroStepBuilder(
                          order: 13,
                          // 화면에 안 나옴
                          text: '5초 후 사이렌과 함께\n비상연락처에 등록 된\n모든 번호로 문자 발송',
                          padding:
                              EdgeInsets.fromLTRB(-2.w, -2.25.h, -2.w, -2.25.h),
                          overlayBuilder: (params) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    // 화면에 나옴
                                    '5초 후 사이렌과 함께\n비상연락처에 등록 된\n모든 번호로 문자 발송',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IntroButton(
                                          onPressed: () {
                                            params.onFinish();
                                            Navigator.of(context).pop();
                                          },
                                          text: '완료',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          builder: (context, key) => AnimatedButton(
                            key: key,
                            height: 17.5.h,
                            width: 50.w,
                            blurRadius: 7.5,
                            isOutline: true,
                            type: PredefinedThemes.danger,
                            onTap: () {},
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    child: Image.asset(
                                      "assets/icons/shadowsiren1.png",
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'S\nO\nS',
                                    style: TextStyle(
                                        fontSize: 17.5.sp,
                                        fontFamily: 'HanSan'),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
