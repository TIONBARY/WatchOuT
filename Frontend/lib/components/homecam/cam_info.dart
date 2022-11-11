import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import '../login/sign_up_text_field.dart';
import '../login/user_service.dart';

class camInfoField extends StatefulWidget {
  const camInfoField({Key? key}) : super(key: key);

  @override
  State<camInfoField> createState() => _camInfoFieldState();
}

class _camInfoFieldState extends State<camInfoField> {
  final _SignupKey = GlobalKey<FormState>();
  String _code = '';
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
            height: 20.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Form(
                  key: _SignupKey,
                  child: SignUpTextField(
                    paddings: EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                    keyboardtypes: TextInputType.text,
                    hinttexts: '코드',
                    helpertexts: '공유 받은 코드를 입력해주세요.',
                    onchangeds: (code) {
                      _code = code;
                    },
                    validations: null,
                  ),
                ),
                Container(
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
                          UserService().homeCamRegister(_code);
                          Navigator.pop(context);
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
        ],
      ),
    );
  }
}
