import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/components/utils/double_click_pop.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/chat_page.dart';
import 'package:homealone/pages/main_page.dart';
import 'package:homealone/pages/set_page.dart';
import 'package:homealone/pages/user_info_page.dart';
import "package:persistent_bottom_nav_bar/persistent_tab_view.dart";

PersistentTabController controller = PersistentTabController(initialIndex: 0);

class TabPage extends StatefulWidget {
  final User user;

  TabPage(this.user);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _selectedIndex = 0;

  late List<Widget> _screens = <Widget>[
    MainPage(),
    ChatPage(),
    UserInfoPage(),
    SetPage(),
  ];

  // 일단 구글 로그인 성공만 확인하고 넘김 페이지 구현 필요(빨간 에러 뜸)

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: 0);
  }

  List<PersistentBottomNavBarItem> _items() {
    return [
      _btnItem(
        title: "홈",
        icon: Icons.home_outlined,
      ),
      _btnItem(
        title: "채팅",
        icon: Icons.message_outlined,
      ),
      _btnItem(
        title: "회원정보",
        icon: Icons.person_outlined,
      ),
      _btnItem(
        title: "환경설정",
        icon: Icons.settings_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        bool result = doubleClickPop();
        return await Future.value(result);
      },
      child: PersistentTabView(
        context,
        controller: controller,
        screens: _screens,
        items: _items(),
        onItemSelected: (index) {},
        backgroundColor: pColor,
        navBarHeight: 48.h,
        navBarStyle: NavBarStyle.style13,
      ),
    );
    // return Scaffold(
    //   body: _pages[_selectedIndex],
    //   bottomNavigationBar: BottomNavigationBar(
    //     fixedColor: Colors.black,
    //     items: <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.message_outlined), label: '채팅'),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.person_outlined), label: '회원정보'),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.settings_outlined), label: '환경설정'),
    //     ],
    //     currentIndex: _selectedIndex,
    //     onTap: _onItemTapped,
    //   ),
    // );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

PersistentBottomNavBarItem _btnItem({
  required String title,
  required IconData icon,
}) {
  return PersistentBottomNavBarItem(
    title: title,
    icon: Icon(icon),
    activeColorPrimary: sColor,
    inactiveColorPrimary: tColor,
    activeColorSecondary: fColor,
  );
}
