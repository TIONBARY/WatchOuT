import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/call_dialog.dart';
import 'package:homealone/components/dialog/cam_info_dialog.dart';
import 'package:homealone/components/homecam/camera_player.dart';
import 'package:homealone/components/homecam/other_cam_Info_shared_page.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/components/main/main_page_animated_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/emergency_manual_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class MainButtonUp extends StatefulWidget {
  @override
  State<MainButtonUp> createState() => _MainButtonUpState();
}

class _MainButtonUpState extends State<MainButtonUp> {
  final _authentication = FirebaseAuth.instance;
<<<<<<< Frontend/lib/components/main/main_button_up.dart
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> emergencyCallList = [];
  Timer? timer;
  String message = "";
  List<String> recipients = [];
  late BuildContext dialogContext;
  final assetsAudioPlayer = AssetsAudioPlayer();
  bool useSiren = false;
  String address = "";
  static const platform = MethodChannel('com.ssafy.homealone/channel');

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
    final status = await Permission.sms.status;
    if (status.isDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                15.h, 'SMS 전송 권한이 없어\n 긴급 호출 문자를 전송하지 않습니다.', null);
          });
      return;
    }
    String _result = await platform.invokeMethod(
        'sendTextMessage', {'message': message, 'recipients': recipients});
    if (_result == "sent") {
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
                12.5.h, "메세지 전송에 실패했습니다.", null);
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
      SharedPreferences pref = await SharedPreferences.getInstance();
      useSiren =
          pref.getBool('useSiren') == null ? false : pref.getBool('useSiren')!;
      print('----------------------${pref.getBool('useSiren')}');
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
    } on PlatformException catch (e) {
      print('sound setting failed');
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
=======
>>>>>>> Frontend/lib/components/main/main_button_up.dart

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
            child: AnimatedButton(
              height: 17.5.h,
              width: 50.w,
              blurRadius: 7.5,
              isOutline: true,
              type: PredefinedThemes.light,
              onTap: () {
                CamDialog(context);
              },
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'C\nA\nM',
                      style: TextStyle(
                        fontSize: 17.5.sp,
                        fontFamily: 'HanSan',
                      ),
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
                    onTap: () async {
                      await launch('https://m.sexoffender.go.kr/main.nsc',
                          forceWebView: false, forceSafariVC: false);
                    },
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
                  colors: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void CamDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
            height: 15.h,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedButton(
                  height: 7.h,
                  width: 30.w,
                  blurRadius: 7.5,
                  isOutline: true,
                  type: PredefinedThemes.light,
                  onTap: () async {
                    bool flag = await UserService().isHomecamRegistered();
                    flag
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraPlayer(),
                            ),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CamInfoDialog(),
                            ),
                          );
                  },
                  child: Text(
                    '나의 캠',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bColor,
                      fontFamily: 'HanSan',
                    ),
                  ),
                ),
                AnimatedButton(
                  height: 7.h,
                  width: 30.w,
                  blurRadius: 7.5,
                  isOutline: true,
                  type: PredefinedThemes.light,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherCamInfo(),
                      ),
                    );
                  },
                  child: Text(
                    '상대방 캠',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bColor,
                      fontFamily: 'HanSan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
