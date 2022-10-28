import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/constants.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class CallDialog extends StatelessWidget {
  String titles = '';
  String names = '';
  String phones = '';
  Widget Function(BuildContext)? pageBuilder;

  Map<String, String> emoji = {
    "편의점": "🏪",
    "파출소": "🚔",
    "약국": "💊",
    "병원": "🏥",
    "안심 택배": "🎁",
    "비상벨": "🔔"
  };

  CallDialog(this.titles, this.names, this.phones, this.pageBuilder);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 10.h, 5.w, 10.h),
        height: 150.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Title(
              color: nColor,
              child: Text(emoji[titles]! + " " + names,
                  style: TextStyle(fontSize: 17.5.sp)),
            ),
            Text(phones.isEmpty ? "등록된 번호가 없습니다." : phones),
            Container(
              padding: EdgeInsets.fromLTRB(0, 17.5.h, 0, 0),
              width: 150.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  phones.isEmpty
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yColor,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: null,
                          child: Text(
                            "통화",
                            style: TextStyle(color: nColor),
                          ))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yColor,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: () {
                            UrlLauncher.launchUrl(Uri.parse("tel:" + phones));
                          },
                          child: Text(
                            "통화",
                            style: TextStyle(color: nColor),
                          ),
                        ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: n25Color,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      "취소",
                      style: TextStyle(color: nColor),
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
