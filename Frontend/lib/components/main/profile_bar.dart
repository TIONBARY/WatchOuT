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
                    onTap: () => print('메인페이지 프로필바 프로필 이미지 선택'),
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
