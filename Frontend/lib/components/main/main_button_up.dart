import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/report_dialog.dart';
import 'package:homealone/components/dialog/sos_dialog.dart';
import 'package:homealone/components/main/main_page_text_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/emergency_manual_page.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:volume_control/volume_control.dart';

ApiKakao apiKakao = ApiKakao();
ApiMessage apiMessage = ApiMessage();

String kakaoMapKey = "";

double initLat = 37.5;
double initLon = 127.5;

bool emergencyFromWidget = false;

class MainButtonUp extends StatefulWidget {
  const MainButtonUp({Key? key}) : super(key: key);

  @override
  State<MainButtonUp> createState() => _MainButtonUpState();
}

class _MainButtonUpState extends State<MainButtonUp> {
  final _authentication = FirebaseAuth.instance;
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> emergencyCallList = [];
  Timer? timer;
  String message = "";
  List<String> recipients = [];
  late BuildContext dialogContext;
  final assetsAudioPlayer = AssetsAudioPlayer();
  bool useSiren = false;
  String address = "";
  static const platform = const MethodChannel('com.ssafy.homealone/sound');

  Future _getKakaoKey() async {
    await dotenv.load();
    kakaoMapKey = dotenv.get('kakaoMapAPIKey');
    FirebaseFirestore.instance
        .collection("user")
        .doc(_authentication.currentUser?.uid)
        .get()
        .then((response) {
      user = response.data() as Map<String, dynamic>;
    });
    return kakaoMapKey;
  }

  void _sendSMS(String message, List<String> recipients) async {
    Map<String, dynamic> _result =
        await apiMessage.sendMessage(recipients, message);
    if (_result["statusCode"] == 200) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '긴급 호출 메세지를 전송했습니다.', null);
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, _result["message"], null);
          });
    }
  }

  void _sendMMS(XFile file, String message, List<String> recipients) async {
    Map<String, dynamic> _result =
        await apiMessage.sendMMSMessage(file, recipients, message);
    if (_result["statusCode"] == 200) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '신고 메세지를 전송했습니다.', null);
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, _result["message"], null);
          });
    }
  }

  void sendEmergencyMessage() async {
    prepareMessage();
    timer = Timer(Duration(seconds: 5), () async {
      Navigator.pop(dialogContext);
      if (recipients.isEmpty) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                  12.5.h, '비상연락처를 등록해주세요.', null);
            });
        return;
      }
      _sendSMS(message, recipients);
      useSiren = Provider.of<SwitchBools>(context, listen: false).useSiren;
      if (useSiren) {
        await _sosSoundSetting();
        VolumeControl.setVolume(0.1);
        assetsAudioPlayer.open(Audio("assets/sounds/siren.mp3"),
            audioFocusStrategy:
                AudioFocusStrategy.request(resumeAfterInterruption: true));
      }
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return SOSDialog();
        }).then((value) {
      timer?.cancel();
    });
  }

  Future<void> _sosSoundSetting() async {
    try {
      final String result = await platform.invokeMethod('sosSoundSetting');
      print("result");
      print(result);
    } on PlatformException catch (e) {
      "Failed to get battery level: '${e.message}'.";
    }
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    initLat = position.latitude;
    initLon = position.longitude;
    address =
        await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
  }

  void prepareMessage() async {
    await getCurrentLocation();
    message =
        "${user?["name"]} 님이 WatchOut 앱에서 SOS 버튼을 눌렀습니다. 긴급 조치가 필요합니다. \n현재 예상 위치 : ${address}\n 이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
    await getEmergencyCallList();
    recipients = [];
    for (var i = 0; i < emergencyCallList.length; i++) {
      recipients.add(emergencyCallList[i]["number"]);
    }
  }

  Future<List<Map<String, dynamic>>> getEmergencyCallList() async {
    final firstResponder = await FirebaseFirestore.instance
        .collection("user")
        .doc(_authentication.currentUser?.uid)
        .collection("firstResponder");
    final result = await firstResponder.get();
    setState(() {
      emergencyCallList = [];
    });
    result.docs.forEach((value) => {
          emergencyCallList
              .add({"name": value.id, "number": value.get("number")})
        });
    return emergencyCallList;
  }

  void sendReportMessage(XFile file) async {
    await getCurrentLocation();
    message =
        "${user?["name"]} 님이 WatchOut 앱에서 신고 버튼을 눌렀습니다. 현재 상황은 위 사진과 같습니다. 긴급 조치가 필요합니다. \n신고자 번호 : ${user?["phone"]}\n현재 예상 위치 : ${address}\n 이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
    recipients = [user?["phone"]];
    _sendMMS(file, message, recipients);
  }

  void _takePhoto() async {
    ImagePicker()
        .getImage(
            source: ImageSource.camera,
            maxHeight: 1500,
            maxWidth: 1500,
            imageQuality: 50)
        .then((PickedFile? recordedImage) {
      if (recordedImage != null) {
        GallerySaver.saveImage(recordedImage.path, albumName: 'Watch OuT')
            .then((bool? success) {});

        XFile file = XFile(recordedImage!.path);
        sendReportMessage(file);
      }
    });
  }

  void _showReportDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ReportDialog(_takePhoto);
        });
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri?.host == 'sos' && !emergencyFromWidget) {
      sendEmergencyMessage();
      emergencyFromWidget = true;
    }
  }

  void _widgetClicked(Uri? uri) {
    if (uri?.host == 'sos') {
      sendEmergencyMessage();
      emergencyFromWidget = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _getKakaoKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_widgetClicked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            children: [
              MainPageTextButton(
                  margins: EdgeInsets.fromLTRB(1.w, 1.h, 2.w, 0.5.h),
                  boxcolors: Colors.black12,
                  onpresseds: _showReportDialog,
                  texts: '신고',
                  textcolors: bColor,
                  fontsizes: 12.5.sp),
              MainPageTextButton(
                margins: EdgeInsets.fromLTRB(1.w, 0.5.h, 2.w, 1.h),
                boxcolors: Colors.black12,
                onpresseds: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.8,
                        child: Container(
                          height: 450.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: EmergencyManual(), // 모달 내부
                        ),
                      );
                    },
                  );
                },
                texts: '위기상황 \n대처메뉴얼',
                textcolors: bColor,
                fontsizes: 12.5.sp,
              ),
            ],
          ),
        ),
        Flexible(
          flex: 2,
          child: IconButton(
            onPressed: () {
              return sendEmergencyMessage();
            },
            icon: Image.asset("assets/icons/shadowsiren2.png"),
            iconSize: 45.w,
          ),
        ),
      ],
    );
  }
}
