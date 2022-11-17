import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:homealone/components/dialog/cam_info_dialog.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:sizer/sizer.dart';

class CameraPlayer extends StatefulWidget {
  const CameraPlayer({Key? key}) : super(key: key);

  @override
  _CameraPlayerState createState() => _CameraPlayerState();
}

class _CameraPlayerState extends State<CameraPlayer> {
  late VlcPlayerController playerController;
  late String url;

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

  Future _future() async {
    return UserService().getHomecamInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: _future(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                style: TextStyle(fontSize: 15),
              ),
            );
          } else {
            url = snapshot.data["url"];
            playerController = VlcPlayerController.network(url, autoPlay: true);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: VlcPlayer(
                      controller: playerController,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AnimatedButton(
                        width: 10.w,
                        blurRadius: 7.5,
                        isOutline: true,
                        type: PredefinedThemes.warning,
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => CamInfoDialog(),
                          );
                        },
                        child: Text(
                          '수\n정',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HanSan',
                          ),
                        ),
                      ),
                      AnimatedButton(
                        width: 10.w,
                        blurRadius: 7.5,
                        isOutline: true,
                        type: PredefinedThemes.danger,
                        onTap: () {
                          UserService().deleteHomecam();
                          Navigator.pop(context);
                        },
                        child: Text(
                          '삭\n제',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HanSan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
