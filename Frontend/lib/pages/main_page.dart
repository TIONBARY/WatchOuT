import 'package:encrypt/encrypt.dart' as en;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/message_dialog.dart';
import 'package:homealone/components/dialog/register_friend_dialog.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/components/main/guide_bar.dart';
import 'package:homealone/components/main/main_button_down.dart';
import 'package:homealone/components/main/main_button_up.dart';
import 'package:sizer/sizer.dart';

import '../components/main/carousel.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    handlePlatformChannelMethods(context);
  }

  Future<dynamic> handlePlatformChannelMethods(BuildContext context) async {
    var result = await platform
        .invokeMethod("getFriendLink")
        .onError((error, stackTrace) => debugPrint(error.toString()));
    if (result.runtimeType == String) {
      //Parameters received from Native…!!!!
      // debugPrint(result);
      await dotenv.load();
      String inviteRandomKey = dotenv.get('inviteRandomKey');
      String decoded = decodeInviteKey(inviteRandomKey, result);
      // TODO: 모달창 열고 onPressed로 이동
      showRegisterFriendDialog(decoded);
    }
  }

  String decodeInviteKey(String inviteRandomKey, String value) {
    //키값
    final key = en.Key.fromUtf8(inviteRandomKey);
    final iv = en.IV.fromLength(16);
    //위에 키값으로 지갑 생성
    final encrypter = en.Encrypter(en.AES(key));

    //생성된 지갑으로 복호화
    final decoded = encrypter.decrypt64(value, iv: iv);
    // debugPrint('-------복호화값: $decoded');
    return decoded;
  }

  void showRegisterFriendDialog(String decoded) async {
    List<String> message = decoded.split(",");
    String expireTimeStr = message[0];
    String inviteCodeStr = message[1];

    debugPrint("초대코드 플러터에서 받음 ㅋㅋ: $inviteCodeStr \n만료일자: $expireTimeStr");
    Map<String, dynamic>? friend =
        await UserService().getOtherUserInfo(inviteCodeStr);
    if (friend == null) {
      Future.microtask(() => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BasicDialog(
                  EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                  12.5.h,
                  '유효하지 않은 초대코드입니다.',
                  null))));
      return;
    }
    String name = friend["name"];
    String phone = friend["phone"];
    DateTime expireTime = DateTime.parse(expireTimeStr);
    // 만료되기 전
    if (expireTime.isAfter(DateTime.now())) {
      showDialog(
          context: context,
          builder: (context) => RegisterFriendDialog(
              () => registerFriend(inviteCodeStr), name, phone));
    } else {
      showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h,
              '만료된 초대코드입니다.',
              null));
    }
  }

  void registerFriend(String inviteCodeStr) async {
    String result =
        await UserService().registerFirstResponderFromInvite(inviteCodeStr);
    if (result == "success") {
      showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h,
              '친구 추가에 성공했습니다.',
              null));
    } else {
      showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h,
              '친구 추가에 실패헀습니다.',
              null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GuideBar(),
          Carousel(),
          Expanded(
            flex: 1,
            child: MainButtonDown(),
          ),
          Expanded(
            flex: 1,
            child: MainButtonUp(),
          ),
        ],
      ),
    );
  }
}
