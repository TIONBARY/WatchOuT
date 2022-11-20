import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/basic_dialog_join.dart';
import 'package:homealone/components/login/sign_up_text_field_suffix.dart';
import 'package:homealone/components/login/sign_up_text_field_validate.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/constants.dart';
import 'package:kpostal/kpostal.dart';
import 'package:sizer/sizer.dart';

class SignUp extends StatefulWidget {
  const SignUp({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignupState();
}

class _SignupState extends State<SignUp> {
  final _SignupKey = GlobalKey<FormState>();

  String postCode = '';
  String region = '';
  String latitude = '';
  String longitude = '';

  String? _name = '';
  String? _nickname = '';
  String? _gender = '';
  String? _phone = '';
  String? _birth = '';

  bool checkDupNum = true;
  bool submitted = false;
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  User? loggedUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Map userData;

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        debugPrint("sign_up.dart에서 user 정보를 잘 받아왔습니다.");
      }
    } catch (e) {
      debugPrint("sign_up.dart에서 유저 정보를 받아오지 못했습니다.");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void _register() async {
    _SignupKey.currentState!.save();
    db.collection("user").doc("${loggedUser!.uid}").update({
      "nickname": _nickname,
      "name": _name,
      "gender": _gender,
      "birth": _birth,
      "phone": _phone,
      "region": '(${this.postCode}) ${this.region}',
      "latitude": '${this.latitude}',
      "longitude": '${this.longitude}',
      "activated": true,
    });
  }

  bool _isValidPhone(String val) {
    return RegExp(r'^010\d{7,8}$').hasMatch(val);
  }

  bool _isValidBirth(String val) {
    if (val.length != 6) return false;
    return RegExp(r'\d{2}([0]\d|[1][0-2])([0][1-9]|[1-2]\d|[3][0-1])')
        .hasMatch(val);
  }

  bool _isValidname(String val) {
    if (val.length > 10 || val.length < 2) // 길이 검사
      return false;
    if (val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) //특수 기호 있으면 false
      return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _SignupKey,
        child: ListView(
          children: [
            Container(
              height: 25.h,
              color: b75Color,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 4.h, 0, 0),
                child: Image(
                  image: AssetImage('assets/WatchOuT_Logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SignUpTextFieldVali(
              validations: (String? val) {
                if (val == null || val.isEmpty) return "이름을 입력해주세요.";
                if (_isValidname(val ?? ''))
                  return null;
                else
                  return "올바른 이름을 입력해주세요.";
              },
              paddings: EdgeInsets.fromLTRB(7.5.w, 5.h, 7.5.w, 1.75.h),
              keyboardtypes: TextInputType.text,
              hinttexts: '이름',
              helpertexts: '한글로 입력해주세요.',
              onchangeds: (name) {
                _name = name;
              },
            ),
            SignUpTextFieldVali(
              validations: (String? val) {
                if (val == null || val.isEmpty) return "생년월일을 입력해주세요.";
                if (!_isValidBirth(val ?? '')) return "올바른 생년월일을 입력해주세요.";
                return null;
              },
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.75.h, 7.5.w, 1.75.h),
              keyboardtypes: TextInputType.number,
              hinttexts: '생년월일',
              helpertexts: 'YYMMDD 형식으로 입력해주세요.',
              onchangeds: (age) {
                _birth = age;
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(7.5.w, 0, 7.5.w, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            '남자',
                            style: TextStyle(
                              color: bColor,
                              fontFamily: 'HanSan',
                            ),
                          ),
                          leading: Radio<String>(
                            value: "M",
                            groupValue: _gender,
                            fillColor: MaterialStateColor.resolveWith(
                              (states) => bColor,
                            ),
                            onChanged: (String? value) {
                              setState(
                                () {
                                  _gender = value;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            '여자',
                            style: TextStyle(
                              color: bColor,
                              fontFamily: 'HanSan',
                            ),
                          ),
                          leading: Radio<String>(
                            value: "F",
                            groupValue: _gender,
                            fillColor: MaterialStateColor.resolveWith(
                                (states) => bColor),
                            onChanged: (String? value) {
                              setState(
                                () {
                                  _gender = value;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SignUpTextFieldSuffix(
              validations: (String? val) {
                if (!_isValidPhone(val ?? '')) {
                  return "올바른 전화번호 형식을 입력해주세요.";
                } else if (!submitted)
                  return "중복 체크를 해주세요.";
                else if (checkDupNum) return "이미 등록된 번호입니다.";
                return null;
              },
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.75.h, 7.5.w, 1.75.h),
              keyboardtypes: TextInputType.number,
              hinttexts: '전화번호',
              helpertexts: '숫자만 입력해주세요.',
              onchangeds: (number) {
                _phone = number;
                setState(() {
                  submitted = false;
                  checkDupNum = true;
                });
              },
              suffix: ElevatedButton(
                onPressed: () async {
                  if (_phone == null ||
                      _phone!.isEmpty ||
                      !_isValidPhone(_phone ?? ''))
                    return setState(() {
                      submitted = false;
                    });
                  checkDupNum = await UserService().isDupNum(_phone!);
                  debugPrint("\nphone : $_phone $checkDupNum\n");

                  //중복인 상황
                  if (checkDupNum) {
                    setState(() {
                      checkDupNum = true;
                      submitted = true;
                    });
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BasicDialog(
                              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                              12.5.h,
                              '이미 등록된 번호입니다.',
                              null);
                        });
                  } else {
                    setState(() {
                      submitted = true;
                      checkDupNum = false;
                    });
                    //중복이 아닌 상황
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BasicDialog(
                              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                              12.5.h,
                              "사용 가능한 번호입니다.",
                              null);
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(2.w, 0.5.h, 2.w, 0.5.h),
                  backgroundColor: bColor,
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "중복 검사",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'HanSan',
                  ),
                ),
              ),
            ),
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.5.w, 1.75.h, 1.25.w, 1.75.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.4.h, 1.25.w, 1.4.h),
                    width: 62.5.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.75.sp,
                          color: b25Color,
                        )),
                    child: (this.postCode.isEmpty && this.region.isEmpty)
                        ? Text(
                            '주소',
                            style: TextStyle(
                              color: b75Color,
                              fontFamily: 'HanSan',
                            ),
                          )
                        : Text(
                            '(${this.postCode}) ${this.region}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: b75Color,
                              fontFamily: 'HanSan',
                            ),
                          ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.fromLTRB(1.25.w, 1.25.h, 0, 1.25.h),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KpostalView(
                              useLocalServer: true,
                              localPort: 8080,
                              // kakaoKey: kakaoMapAPIKey,
                              callback: (Kpostal result) {
                                setState(
                                  () {
                                    this.postCode = result.postCode;
                                    this.region = result.address;
                                    this.latitude = result.latitude.toString();
                                    this.longitude =
                                        result.longitude.toString();
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '우편번호',
                        style: TextStyle(
                          fontFamily: 'HanSan',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30.w, 1.75.h, 30.w, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {
                  if (_SignupKey.currentState!.validate() &&
                      !checkDupNum &&
                      submitted) {
                    showDialog(
                        context: context,
                        builder: (context) => BasicDialogJoin(
                            '회원가입에 성공했습니다.', () => _register()));
                  } else if (!_SignupKey.currentState!.validate()) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BasicDialog(
                            EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                            12.5.h,
                            '회원 정보를 입력해주세요.',
                            null,
                          );
                        });
                  } else if (checkDupNum) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BasicDialog(
                              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                              12.5.h,
                              '중복된 번호입니다.',
                              null);
                        });
                  } else if (!submitted) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BasicDialog(
                              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                              12.5.h,
                              "중복 체크 해주세요.",
                              null);
                        });
                  }
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: yColor,
                    fontFamily: 'HanSan',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
