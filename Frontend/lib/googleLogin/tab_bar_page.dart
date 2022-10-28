import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/pages/main_page.dart';
import 'package:homealone/pages/record_page.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:homealone/pages/set_page.dart';
import 'package:sizer/sizer.dart';

import '../components/login/auth_service.dart';
import '../constants.dart';

class TabNavBar extends StatefulWidget {
  final User user;

  TabNavBar(this.user);

  @override
  State<TabNavBar> createState() => _TabNavBarState();
}

class _TabNavBarState extends State<TabNavBar> {
  final _authentication = FirebaseAuth.instance;

  late TabController _tabController;

  final _selectedColor = nColor;
  final _unselectedColor = Color(0xff5f6368);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('WatchOut',
              style: TextStyle(color: yColor, fontSize: 25.sp)),
          centerTitle: true,
          backgroundColor: nColor,
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                AuthService().signOut();
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
                  unselectedLabelColor: nColor,
                  tabs: [
                    Tab(text: '홈'),
                    Tab(text: '안전지대'),
                    Tab(text: '기록'),
                    Tab(text: '설정'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    MainPage(),
                    SafeAreaCCTVMapPage(),
                    RecordPage(),
                    SetPage(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
