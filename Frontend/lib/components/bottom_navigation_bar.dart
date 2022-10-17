import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/components/utils/double_click_pop.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/chat_page.dart';
import 'package:homealone/pages/main_page.dart';
import 'package:homealone/pages/set_page.dart';
import 'package:homealone/pages/user_info_page.dart';
import "package:persistent_bottom_nav_bar/persistent_tab_view.dart";

PersistentTabController controller = PersistentTabController(initialIndex: 0);

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  List<Widget> _screens = <Widget>[
    MainPage(),
    ChatPage(),
    UserInfoPage(),
    SetPage(),
  ];

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
