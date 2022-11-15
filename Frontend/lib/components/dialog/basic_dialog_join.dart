import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class BasicDialogJoin extends StatefulWidget {
  const BasicDialogJoin(this.function, {Key? key}) : super(key: key);
  final Function function;
  @override
  State<BasicDialogJoin> createState() => _BasicDialogJoinState();
}

class _BasicDialogJoinState extends State<BasicDialogJoin> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
        height: 13.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: Text(
                "회원 가입에 성공하셨습니다.",
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
            Container(
              width: 15.w,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: yColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () {
                  widget.function();
                  Navigator.of(context).pop();
                },
                child: Text(
                  '확인',
                  style: TextStyle(color: bColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
