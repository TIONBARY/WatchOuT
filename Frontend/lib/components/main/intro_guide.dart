import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('WatchOuT', style: TextStyle(color: yColor, fontSize: 20.sp)),
        backgroundColor: bColor,
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(1.w, 1.h, 1.w, 1.h),
            child: IntroStepBuilder(
              order: 1,
              text: '클릭 시 회원정보 수정',
              padding: EdgeInsets.only(
                bottom: 1,
                left: 1,
                right: 1,
                top: 1,
              ),
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: kToolbarHeight - 8.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: Row(
                children: [
                  IntroStepBuilder(
                    order: 2,
                    text: '클릭 시 홈 화면',
                    padding: EdgeInsets.only(
                      bottom: 1,
                      left: 1,
                      right: 1,
                      top: 1,
                    ),
                    builder: (context, key) => Expanded(
                      key: key,
                      flex: 1,
                      child: Container(
                        height: kToolbarHeight - 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: bColor,
                        ),
                        child: Center(
                          child: Text(
                            '홈',
                            style: TextStyle(color: yColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IntroStepBuilder(
                    order: 3,
                    text: '클릭 시 안전 지도 화면',
                    padding: EdgeInsets.only(
                      bottom: 1,
                      left: 1,
                      right: 1,
                      top: 1,
                    ),
                    builder: (context, key) => Expanded(
                      key: key,
                      flex: 1,
                      child: Container(
                        height: kToolbarHeight - 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            '안전 지도',
                            style: TextStyle(color: bColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IntroStepBuilder(
                    order: 4,
                    text: '클릭 시 귀가 공유 화면',
                    padding: EdgeInsets.only(
                      bottom: 1,
                      left: 1,
                      right: 1,
                      top: 1,
                    ),
                    builder: (context, key) => Expanded(
                      key: key,
                      flex: 1,
                      child: Container(
                        height: kToolbarHeight - 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            '귀가 공유',
                            style: TextStyle(color: bColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IntroStepBuilder(
                    order: 5,
                    text: '클릭 시 설정 화면',
                    padding: EdgeInsets.only(
                      bottom: 1,
                      left: 1,
                      right: 1,
                      top: 1,
                    ),
                    builder: (context, key) => Expanded(
                      key: key,
                      flex: 1,
                      child: Container(
                        height: kToolbarHeight - 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            '설정',
                            style: TextStyle(color: bColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
