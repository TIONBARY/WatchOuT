import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class CallDialog extends StatelessWidget {
  final String? titles;
  final String names;
  final String phones;
  final String? texts;
  final Widget Function(BuildContext)? pageBuilder;

  final Map<String, String> emoji = {
    "νΈμμ ": "πͺ",
    "νμΆμ": "π",
    "μ½κ΅­": "π",
    "λ³μ": "π₯",
    "μμ¬ νλ°°": "π",
    "λΉμλ²¨": "π"
  };

  CallDialog(this.titles, this.names, this.phones, this.texts, this.pageBuilder,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 1.5.h),
        height: (this.texts == null) ? 15.h : 25.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: (this.titles == null)
                  ? Text(
                      names,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontFamily: 'HanSan',
                      ),
                    )
                  : Text(emoji[titles]! + " " + names,
                      style: TextStyle(fontSize: 12.5.sp)),
            ),
            Text(phones.isEmpty ? "λ±λ‘λ λ²νΈκ° μμ΅λλ€." : phones),
            (this.texts == null)
                ? Padding(padding: EdgeInsets.zero)
                : Text(texts!, textAlign: TextAlign.center),
            Container(
              width: 35.w,
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
                            "ν΅ν",
                            style: TextStyle(color: bColor),
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
                            "ν΅ν",
                            style: TextStyle(
                              color: bColor,
                              fontFamily: 'HanSan',
                            ),
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
                      if (pageBuilder == null) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.push(
                            context, MaterialPageRoute(builder: pageBuilder!));
                      }
                    },
                    child: Text(
                      "μ·¨μ",
                      style: TextStyle(
                        color: bColor,
                        fontFamily: 'HanSan',
                      ),
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
