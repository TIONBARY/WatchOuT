import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog(this.func, {Key? key}) : super(key: key);

  final Function func;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
        height: 25.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: Text(
                "사진 촬영 시 112로 신고 문자가 전송됩니다. \n정말 전송하시겠습니까?",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              width: 35.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    onPressed: () {
                      widget.func();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '전송',
                      style: TextStyle(color: bColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: b25Color,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "취소",
                      style: TextStyle(color: bColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
