import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/components/dialog/sos_dialog.dart';
import 'package:homealone/components/main/main_page_text_button.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

ApiKakao apiKakao = ApiKakao();

String kakaoMapKey = "";

double initLat = 37.5;
double initLon = 127.5;

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
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  void sendEmergencyMessage() async {
    prepareMessage();
    timer = Timer(Duration(seconds: 5), () {
      Navigator.pop(dialogContext);
      _sendSMS(message, recipients);
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

  void prepareMessage() async {
    Position position = await Geolocator.getCurrentPosition();
    initLat = position.latitude;
    initLon = position.longitude;
    String address =
        await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
    message =
        "${user?["name"]} 님이 WatchOut 앱에서 SOS 버튼을 눌렀습니다. 긴급 조치가 필요합니다. \n현재 예상 위치 : ${address}\n 이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
    await getEmergencyCallList();
    recipients = ["112"];
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

  @override
  void initState() {
    super.initState();
    _getKakaoKey();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MainPageTextButton(
            flexs: 2,
            margins: EdgeInsets.fromLTRB(2.w, 1.h, 1.w, 1.h),
            boxcolors: Colors.red,
            onpresseds: () {
              sendEmergencyMessage();
            },
            texts: 'SOS',
            textcolors: Colors.white,
            fontsizes: 40.sp),
        Flexible(
            child: Column(
          children: [
            MainPageTextButton(
                flexs: 1,
                margins: EdgeInsets.fromLTRB(1.w, 1.h, 2.w, 0.5.h),
                boxcolors: Colors.black12,
                onpresseds: () {},
                texts: '미정',
                textcolors: nColor,
                fontsizes: 12.5.sp),
            MainPageTextButton(
                flexs: 1,
                margins: EdgeInsets.fromLTRB(1.w, 0.5.h, 2.w, 1.h),
                boxcolors: Colors.black12,
                onpresseds: () {},
                texts: '미정',
                textcolors: nColor,
                fontsizes: 12.5.sp)
          ],
        ))
      ],
    );
  }
}
