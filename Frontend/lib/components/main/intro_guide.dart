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
            CircleAvatar(
              backgroundImage: AssetImage('assets/icons/shadowsiren.png'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              IntroStepBuilder(
                order: 1,
                text: '탭바',
                onWidgetLoad: () {
                  Intro.of(context).start();
                },
                padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                builder: (context, key) => Container(
                  key: key,
                  height: kToolbarHeight - 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: Row(
                    children: [
                      Expanded(
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
                      Expanded(
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
                      Expanded(
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
                      Expanded(
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
                    ],
                  ),
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
                    ElevatedButton(
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
                  ],
                ),
              ),
              IntroStepBuilder(
                order: 2,
                text: '안전 교육 영상',
                padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                builder: (context, key) => Expanded(
                  key: key,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                    child: Image.asset(
                      'assets/guidesample.jpg',
                    ),
                  ),
                ),
              ),
              IntroStepBuilder(
                order: 3,
                text: '상단 버튼',
                padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                builder: (context, key) => Expanded(
                  key: key,
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          flex: 3,
                          child: AnimatedButton(
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
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                child: AnimatedButton(
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
                              MainPageAniBtn(
                                margins: EdgeInsets.only(bottom: 4),
                                types: PredefinedThemes.primary,
                                ontaps: () {},
                                texts: '안심귀가\n서비스',
                                colors: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IntroStepBuilder(
                order: 4,
                text: '하단 버튼',
                overlayBuilder: (params) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        // 화면에 나옴
                        '하단 버튼',
                        style: TextStyle(color: Colors.white),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      IntroButton(
                        onPressed: () {
                          params.onFinish();
                          Navigator.of(context).pop();
                        },
                        text: '완료',
                      ),
                    ],
                  );
                },
                padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                builder: (context, key) => Expanded(
                  key: key,
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
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                child: AnimatedButton(
                                  width: 30.w,
                                  blurRadius: 7.5,
                                  isOutline: true,
                                  type: null,
                                  color: oColor,
                                  onTap: () async {},
                                  child: Text(
                                    '신고',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: bColor,
                                      fontFamily: 'HanSan',
                                    ),
                                  ),
                                ),
                              ),
                              MainPageAniBtn(
                                margins: EdgeInsets.only(bottom: 4),
                                types: PredefinedThemes.warning,
                                ontaps: () {},
                                texts: '위기상황 \n대처메뉴얼',
                                colors: bColor,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: AnimatedButton(
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
                      ],
                    ),
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
