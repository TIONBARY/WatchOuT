import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class CameraGif extends StatefulWidget {
  const CameraGif({Key? key}) : super(key: key);

  @override
  State<CameraGif> createState() => _CameraGifState();
}

class _CameraGifState extends State<CameraGif> {
  @override
  void initState() {
    // 가로 화면 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    super.initState();
  }

  @override
  void dispose() {
    // 세로 화면 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 5,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/test/loopCam.gif'),
                        fit: BoxFit.contain),
                  ),
                )),
          ),
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedButton(
                  width: 15.w,
                  height: 20.h,
                  blurRadius: 7.5,
                  isOutline: true,
                  type: PredefinedThemes.warning,
                  child: Text(
                    '수\n정',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontFamily: 'HanSan',
                    ),
                  ),
                ),
                AnimatedButton(
                  width: 15.w,
                  height: 20.h,
                  blurRadius: 7.5,
                  isOutline: true,
                  type: PredefinedThemes.danger,
                  child: Text(
                    '삭\n제',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontFamily: 'HanSan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    //   Container(
    //   decoration: BoxDecoration(
    //     image: DecorationImage(
    //         image: AssetImage('assets/test/loopCam.gif'), fit: BoxFit.contain),
    //   ),
    // );
    ;
  }
}
