import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import '../login/sign_up_text_field.dart';
import 'others_cam.dart';

class otherCamInfoField extends StatefulWidget {
  const otherCamInfoField({Key? key}) : super(key: key);

  @override
  State<otherCamInfoField> createState() => _otherCamInfoFieldState();
}

class _otherCamInfoFieldState extends State<otherCamInfoField> {
  bool isLoading = true;
  String _code = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          children: [
            _code == ''
                ? Container(
                    alignment: Alignment.center,
                    child: Text(
                      "시청 가능한 사용자가 없습니다.",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  )
                : OthersCam(
                    url: '$_code',
                  ),
            Positioned(
              right: 1.25.w,
              bottom: 1.25.h,
              child: FloatingActionButton(
                heroTag: "other_cam_info_field_edit",
                backgroundColor: bColor,
                onPressed: () {
                  _CodeDialog(context);
                },
                child: Icon(
                  Icons.edit,
                  size: 20.sp,
                ),
              ),
            ),
            Positioned(
              left: 1.25.w,
              bottom: 1.25.h,
              child: FloatingActionButton(
                heroTag: "other_cam_info_field_update",
                elevation: 5,
                hoverElevation: 10,
                tooltip: "귀가 공유 리스트 갱신",
                backgroundColor: bColor,
                onPressed: () {},
                child: Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _CodeDialog(BuildContext context) async {
    final _SignupKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
            height: 20.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Form(
                  key: _SignupKey,
                  child: SignUpTextField(
                    validations: null,
                    paddings: EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                    keyboardtypes: TextInputType.number,
                    hinttexts: '웹캠주소',
                    helpertexts: '공유 받은 웹캠 주소를 입력해주세요.',
                    onchangeds: (code) {
                      _code = code;
                    },
                  ),
                ),
                Container(
                  width: 37.5.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: Text(
                          '등록',
                          style: TextStyle(
                            color: bColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: b25Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          '취소',
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
      },
    );
  }
}
