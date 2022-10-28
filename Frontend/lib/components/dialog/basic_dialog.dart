import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class BasicDialog extends StatelessWidget {
  String titles = '';
  Widget Function(BuildContext)? pageBuilder;

  BasicDialog(this.titles, this.pageBuilder);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(1.w, 2.h, 1.w, 2.h),
        height: 15.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Title(
              color: nColor,
              child: Text(titles),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 1.h, 0, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: n25Color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () {
                  if (pageBuilder == null) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.push(
                        context, MaterialPageRoute(builder: pageBuilder!));
                  }
                },
                child: Text(
                  '확인',
                  style: TextStyle(color: nColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
