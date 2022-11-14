import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';

class CustomDialog extends StatelessWidget {
  final String text;
  final Widget Function(BuildContext)? pageBuilder;

  CustomDialog(this.text, this.pageBuilder, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)), //this right here
      child: Container(
        height: 100.h,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Title(
                color: bColor,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Container(
                width: 60.w,
                margin: EdgeInsets.fromLTRB(0, 10.h, 0, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    backgroundColor: bColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    "확인",
                    style: TextStyle(
                      color: Colors.cyan,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
