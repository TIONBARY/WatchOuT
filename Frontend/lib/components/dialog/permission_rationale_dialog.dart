import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class PermissionRationaleDialog extends StatelessWidget {
  final Permission permission;
  final String message;

  PermissionRationaleDialog(this.permission, this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(7.5.w, 2.5.h, 7.5.w, 1.25.h),
        height: 32.5.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: Text(
                "권한 요청",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: 'HanSan',
                ),
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: () async {
                // if (await permission.request().isGranted) {
                await permission.request();
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setBool("permissionOnce", true);
                Navigator.pop(context);
                // }
              },
              child: Text(
                '확인',
                style: TextStyle(
                  color: bColor,
                  fontFamily: 'HanSan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
