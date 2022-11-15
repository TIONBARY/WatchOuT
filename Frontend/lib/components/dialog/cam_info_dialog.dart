import 'package:flutter/material.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class CamInfoDialog extends StatefulWidget {
  CamInfoDialog({super.key});

  @override
  State<CamInfoDialog> createState() => _CamInfoDialogState();
}

class _CamInfoDialogState extends State<CamInfoDialog> {
  final _signupKey = GlobalKey<FormState>();
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
        height: 20.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              key: _signupKey,
              child: SignUpTextField(
                paddings: EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                keyboardtypes: TextInputType.text,
                hinttexts: '주소',
                helpertexts: '캠 주소를 입력해주세요.',
                onchangeds: (code) {
                  _code = code;
                },
                validations: null,
              ),
            ),
            SizedBox(
              width: 37.5.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    onPressed: () {
                      _code.contains('://')
                          ? {
                              UserService().homeCamRegister(_code),
                              Navigator.pop(context)
                            }
                          : showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return BasicDialog(EdgeInsets.all(10), 10.h,
                                    '주소를 확인해주세요.', null);
                              },
                            );
                    },
                    child: Text(
                      '등록',
                      style: TextStyle(
                        color: bColor,
                        fontFamily: 'HanSan',
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
