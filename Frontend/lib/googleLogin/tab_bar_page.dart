import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/message_dialog.dart';
import 'package:homealone/components/dialog/register_friend_dialog.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/components/utils/double_click_pop.dart';
import 'package:homealone/googleLogin/modify_userinfo_page.dart';
import 'package:homealone/googleLogin/sign_up_page.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../constants.dart';
import '../pages/main_page.dart';
import '../pages/set_page.dart';
import '../pages/shared_page.dart';

class TabNavBar extends StatefulWidget {
  @override
  State<TabNavBar> createState() => _TabNavBarState();
}

class _TabNavBarState extends State<TabNavBar> {
  late bool check;
  final _selectedColor = bColor;

  Future<void> checkUserInfo() async {
    check = await UserService().isActivated();
    if (!check) {
      debugPrint("너 왜 가입 안했냐?");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUpPage()));
    }
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

    debugPrint("초대코드 플러터에서 받음: $inviteCodeStr \n만료일자: $expireTimeStr");
    Map<String, dynamic>? friend =
        await UserService().getOtherUserInfo(inviteCodeStr);
    if (friend == null) {
      showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h,
              '유효하지 않은 초대코드입니다.',
              null));
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
  void initState() {
    super.initState();
    checkUserInfo();
    handlePlatformChannelMethods(context);
    // permitLocation();
  }

  // void permitLocationAlways() async {
  //   if (await Permission.locationAlways.isGranted != true &&
  //       await Permission.location.isGranted) {
  //     PermissionService().permissionLocationAlways(context);
  //   }
  // }

  // void permitLocation() async {
  //   if (await Permission.location.isDenied) {
  //     PermissionService().permissionLocation(context);
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool result = doubleClickPop();
        return await Future.value(result);
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              'WatchOuT',
              style: TextStyle(
                color: yColor,
                fontSize: 20.sp,
                fontFamily: 'HanSan',
              ),
            ),
            backgroundColor: bColor,
            actions: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.88,
                        child: Container(
                          height: 450.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: ModifyUserInfoPage(), // 모달 내부
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 1.h),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        Provider.of<MyUserInfo>(context, listen: false)
                            .profileImage),
                  ),
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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TabBar(
                    labelStyle: TextStyle(
                      fontFamily: 'HanSan',
                    ),
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: _selectedColor),
                    labelColor: yColor,
                    unselectedLabelColor: bColor,
                    tabs: [
                      Tab(
                        text: '홈',
                      ),
                      Tab(text: '안전 지도'),
                      Tab(text: '귀가 공유'),
                      Tab(text: '설정'),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      MainPage(),
                      SafeAreaCCTVMapPage(),
                      RecordPage(),
                      SetPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
