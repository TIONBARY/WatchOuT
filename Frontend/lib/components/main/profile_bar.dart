import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProfileBar extends StatefulWidget {
  const ProfileBar({Key? key}) : super(key: key);

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              child: SizedBox(
                height: 25.h,
                width: 25.w,
                child: CircleAvatar(
                  backgroundColor: nColor,
                  child: GestureDetector(
                    onTap: () => todayCheck(),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 7,
            child: Container(
              child: Text(
                Provider.of<MyUserInfo>(context, listen: false).nickname,
                style: TextStyle(fontSize: 17.5.sp),
              ),
            ),
          ),
          // Flexible(flex: 3, child: Image.asset('assets/heartbeat.gif')),
        ],
      ),
    );
  }
}

void todayCheck() {
  DateTime now = DateTime.now();
  Timer(
    Duration(seconds: 20),
    () {
      DateTime later = DateTime.now();
      int time_diff = ((later.year - now.year) * 8760 * 3600) +
          ((later.month - now.month) * 730 * 3600) +
          ((later.day - now.day) * 24 * 3600) +
          ((later.hour - now.hour) * 3600) +
          ((later.minute - now.minute) * 60) +
          (later.second - now.second);

      print('시간 차이 ${time_diff}');
    },
  );
}
