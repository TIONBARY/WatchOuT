import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/pages/main_page.dart';
import 'package:homealone/pages/record_page.dart';
import 'package:homealone/pages/safe_area_page.dart';
import 'package:homealone/pages/set_page.dart';

class TabNavBar extends StatefulWidget {
  final User user;

  TabNavBar(this.user);

  @override
  State<TabNavBar> createState() => _TabNavBarState();
}

class _TabNavBarState extends State<TabNavBar> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('WatchOut'),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.exit_to_app_sharp,
                  color: Colors.white,
                ),
                onPressed: () {
                  _authentication.signOut();
                },
              )
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: '홈'),
                Tab(text: '안전지대'),
                Tab(text: '기록'),
                Tab(text: '설정'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MainPage(),
              SafeAreaPage(),
              RecordPage(),
              SetPage(),
            ],
          ),
        ));
  }
}
