import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/constants.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class SafeAreaDialog extends StatelessWidget {
  String title = "";
  String name = "";
  String phone = "";
  Widget Function(BuildContext)? pageBuilder;

  Map<String, String> emoji = {
    "편의점": "🏪",
    "파출소": "🚔",
    "약국": "💊",
    "병원": "🏥",
    "안심 택배": "🎁",
    "비상벨": "🔔"
  };

  SafeAreaDialog(this.title, this.name, this.phone, this.pageBuilder);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)), //this right here
      child: Container(
        height: 140.h,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Title(
                color: nColor,
                child: Text(emoji[title]! + " " + name,
                    style: TextStyle(fontSize: 18.sp, fontFamily: "Sub")),
              ),
              Text(phone.isEmpty ? "등록된 번호가 없습니다." : phone),
              Container(
                  width: 150.w,
                  margin: EdgeInsets.fromLTRB(0, 10.h, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      phone.isEmpty
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(0),
                                backgroundColor: yColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: null,
                              child: Text(
                                "통화",
                                style:
                                    TextStyle(color: nColor, fontFamily: "Sub"),
                              ))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(0),
                                backgroundColor: yColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                UrlLauncher.launchUrl(
                                    Uri.parse("tel:" + phone));
                              },
                              child: Text(
                                "통화",
                                style:
                                    TextStyle(color: nColor, fontFamily: "Sub"),
                              ),
                            ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(0),
                          backgroundColor: n25Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          if (pageBuilder == null) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: pageBuilder!));
                          }
                        },
                        child: Text(
                          "취소",
                          style: TextStyle(color: nColor, fontFamily: "Sub"),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
