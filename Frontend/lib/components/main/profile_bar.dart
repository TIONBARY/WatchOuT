import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.fromLTRB(25.w, 15.h, 25.w, 5.h),
      child: Row(
        children: [
          Flexible(
              child: Container(
            child: SizedBox(
              height: 75.h,
              width: 75.w,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: GestureDetector(
                  onTap: () => print('메인페이지 프로필바 프로필 이미지 선택'),
                ),
              ),
            ),
          )),
          Flexible(
              child: Container(
            padding: EdgeInsets.fromLTRB(12.5.w, 0, 12.5.w, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    child: Container(
                  child: Text(
                    'User 님',
                    style: TextStyle(fontSize: 25.sp),
                  ),
                )),
                Flexible(
                    child: Container(
                  child: Text(
                    '안녕하세요',
                    style: TextStyle(fontSize: 12.5.sp),
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
