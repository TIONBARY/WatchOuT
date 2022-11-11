import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
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
  final _SignupKey = GlobalKey<FormState>();
  String _code = '';
  late String url;
  Future _future() async {
    return UserService().getHomecamInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cam',
      home: Scaffold(
          // appBar: AppBar(),
          body: FutureBuilder(
        future: _future(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data["registered"] == null) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("연결된 카메라가 없습니다."),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _CodeDialog(context);
                        });
                      },
                      child: Text("입력")),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                style: TextStyle(fontSize: 15),
              ),
            );
          } else if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else if (!(snapshot.data == null) && !snapshot.data["registered"]) {
            //등록되어 있지 않다면
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("연결된 카메라가 없습니다."),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _CodeDialog(context);
                        });
                      },
                      child: Text("입력")),
                ],
              ),
            );
          } else {
            url = snapshot.data["url"];
            playerController = VlcPlayerController.network("${url}",
                // "rtsp://watchout:ssafy123@70.12.227.183/stream1",
                autoPlay: true);
            return Column(
              children: [
                VlcPlayer(
                  controller: playerController,
                  aspectRatio: 16 / 9,
                  placeholder: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    playerController.play();
                  },
                  child: const Text("Play"),
                ),
                ElevatedButton(
                  onPressed: () {
                    playerController.pause();
                  },
                  child: const Text("Pause"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _CodeDialog(context);
                  },
                  child: const Text("수정"),
                ),
                ElevatedButton(
                  onPressed: () {
                    UserService().deleteHomecam();
                    Navigator.pop(context);
                  },
                  child: const Text("삭제"),
                ),
              ],
            );
          }
        },
      )),
    );
  }

  Future<void> _CodeDialog(BuildContext context) async {
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
                      key: _SignupKey,
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
                    Container(
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
