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
    return Row(
      children: [
        Flexible(
            child: Container(
          margin: EdgeInsets.fromLTRB(25.w, 0, 0, 0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 50,
            child: GestureDetector(
              onTap: () => print('메인페이지 프로필바 프로필 이미지 선택'),
            ),
          ),
        ))
      ],
    );
  }
}
