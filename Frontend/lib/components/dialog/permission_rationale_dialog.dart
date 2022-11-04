import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class PermissionRationaleDialog extends StatelessWidget {
  Permission permission = Permission.unknown;
  String message = '';
  PermissionRationaleDialog(this.permission, this.message);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.all(5.h),
        height: 50.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(color: Colors.white.withOpacity(1), child: Text("권한 요청")),
            Text(message),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: () async {
                if (await permission.request().isGranted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                '확인',
                style:
                    TextStyle(color: Colors.lightBlueAccent.withOpacity(1.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
