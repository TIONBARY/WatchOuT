import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainButtonDown extends StatefulWidget {
  const MainButtonDown({Key? key}) : super(key: key);

  @override
  State<MainButtonDown> createState() => _MainButtonDownState();
}

class _MainButtonDownState extends State<MainButtonDown> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(
              flex: 1,
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10.w, 10.h, 5.w, 5.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.red),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10.w, 5.h, 5.w, 10.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.orange),
                    ),
                  ),
                ],
              )),
          Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.fromLTRB(5.w, 5.h, 10.w, 5.h),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Colors.yellow),
              ))
        ],
      ),
    );
  }
}
