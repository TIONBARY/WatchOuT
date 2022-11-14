import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import '../login/sign_up_text_field.dart';
import '../login/user_service.dart';

void main() {
  runApp(const MaterialApp(
    home: CameraPlayerWidget(),
  ));
}

class CameraPlayerWidget extends StatefulWidget {
  const CameraPlayerWidget({Key? key}) : super(key: key);

  @override
  _CameraPlayerWidgetState createState() => _CameraPlayerWidgetState();
}

class _CameraPlayerWidgetState extends State<CameraPlayerWidget> {
  late VlcPlayerController playerController;
  final _signupKey = GlobalKey<FormState>();
  String _code = '';
  late String url;
  Future _future() async {
    return UserService().getHomecamInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('WatchOuT',
              style: TextStyle(color: yColor, fontSize: 20.sp)),
          backgroundColor: bColor,
          actions: [
            Container(
              padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 1.h),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    Provider.of<MyUserInfo>(context, listen: false)
                        .profileImage),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _future(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData == false) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                  style: TextStyle(fontSize: 15),
                ),
              );
            } else {
              url = snapshot.data["url"];
              playerController =
                  VlcPlayerController.network(url, autoPlay: true);
              return Column(
                children: [
                  VlcPlayer(
                    controller: playerController,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(3.sp)),
                  AnimatedButton(
                    height: 7.h,
                    width: 30.w,
                    blurRadius: 7.5,
                    isOutline: true,
                    type: PredefinedThemes.light,
                    onTap: () {
                      playerController.play();
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Play',
                            style: TextStyle(fontSize: 12.sp, color: bColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(3.sp)),
                  AnimatedButton(
                    height: 7.h,
                    width: 30.w,
                    blurRadius: 7.5,
                    isOutline: true,
                    type: PredefinedThemes.light,
                    onTap: () {
                      playerController.pause();
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Pause',
                            style: TextStyle(fontSize: 12.sp, color: bColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(3.sp)),
                  AnimatedButton(
                    height: 7.h,
                    width: 30.w,
                    blurRadius: 7.5,
                    isOutline: true,
                    type: PredefinedThemes.light,
                    onTap: () {
                      _codeDialog(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '수정',
                            style: TextStyle(fontSize: 12.sp, color: bColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(3.sp)),
                  AnimatedButton(
                    height: 7.h,
                    width: 30.w,
                    blurRadius: 7.5,
                    isOutline: true,
                    type: PredefinedThemes.light,
                    onTap: () {
                      UserService().deleteHomecam();
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '삭제',
                            style: TextStyle(fontSize: 12.sp, color: bColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ));
  }

  Future<void> _codeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
                height: 20.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Form(
                      key: _signupKey,
                      child: SignUpTextField(
                        paddings:
                            EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                        keyboardtypes: TextInputType.text,
                        hinttexts: '코드',
                        helpertexts: '공유 받은 코드를 입력해주세요.',
                        onchangeds: (code) {
                          _code = code;
                        },
                        validations: null,
                      ),
                    ),
                    SizedBox(
                      width: 37.5.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: yColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                UserService().homeCamRegister(_code);
                                Navigator.pop(context);
                              });
                            },
                            child: Text(
                              '등록',
                              style: TextStyle(
                                color: bColor,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: b25Color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '취소',
                              style: TextStyle(color: bColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
