import 'package:flutter/material.dart';
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
