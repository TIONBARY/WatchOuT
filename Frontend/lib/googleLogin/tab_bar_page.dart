import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/components/utils/double_click_pop.dart';
import 'package:homealone/googleLogin/sign_up_page.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:sizer/sizer.dart';

import '../components/login/auth_service.dart';
import '../constants.dart';
import '../main.dart';
import '../pages/main_page.dart';
import '../pages/set_page.dart';
import '../pages/shared_page.dart';

class TabNavBar extends StatefulWidget {
  @override
  State<TabNavBar> createState() => _TabNavBarState();
}

class _TabNavBarState extends State<TabNavBar> {
  final _authentication = FirebaseAuth.instance;
  late bool check;
  late TabController _tabController;
  final _selectedColor = bColor;
  final _unselectedColor = Color(0xff5f6368);

  Future<void> checkUserInfo() async {
    check = await UserService().isActivated();
    if (!check) {
      print("너 왜 가입 안했냐?");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUpPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserInfo();
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
            title: Text('WatchOuT',
                style: TextStyle(color: yColor, fontSize: 20.sp)),
            centerTitle: true,
            backgroundColor: bColor,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.exit_to_app_sharp,
                  color: Colors.white,
                ),
                onPressed: () {
                  AuthService().signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                      (route) => false);
                },
              )
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
                    labelColor: yColor,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: _selectedColor),
                    unselectedLabelColor: bColor,
                    tabs: [
                      Tab(text: '홈'),
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
