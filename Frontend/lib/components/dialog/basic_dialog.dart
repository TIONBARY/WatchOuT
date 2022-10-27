import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/constants.dart';

class BasicDialog extends StatelessWidget {
  String titles = '';
  String texts = '';
  Widget Function(BuildContext)? pageBuilder;

  BasicDialog(this.titles, this.texts, this.pageBuilder);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 10.h, 5.w, 10.h),
        height: 100.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Title(
              color: nColor,
              child: Text(titles),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: n25Color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5),
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
              child: Text(texts),
            ),
          ],
        ),
      ),
    );
  }
}
