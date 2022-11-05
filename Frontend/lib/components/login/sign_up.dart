import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
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
  final TextEditingController _textController = new TextEditingController();
  Widget _changedTextWidget = Container();

  final _SignupKey = GlobalKey<FormState>();

  String postCode = '';
  String region = '';
  String latitude = '-';
  String longitude = '-';

  String? _name = '';
  String? _nickname = '';
  String? _gender = '';
  String? _phone = '';
  String? _birth = '';

  final FirebaseAuth _authentication = FirebaseAuth.instance;
  User? loggedUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Map userData;

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print("sign_up.dart에서 user 정보를 잘 받아왔습니다.");
      }
    } catch (e) {
      print("sign_up.dart에서 유저 정보를 받아오지 못했습니다.");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> _register() async {
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
    return RegExp(r'(?:[0]9)?[0-9]{6}$').hasMatch(val);
  }

  bool _isValidname(String val) {
    if (val.length > 10 && val.length < 2) // 길이 검사
      return false;
    if (val.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) //특수 기호 있으면 false
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
            SignUpTextField(
              validations: (String? val) {
                return _isValidname(val ?? '') ? null : "올바른 이름을 입력해주세요.";
              },
              paddings: EdgeInsets.fromLTRB(7.5.w, 5.h, 7.5.w, 1.75.h),
              keyboardtypes: TextInputType.text,
              hinttexts: '이름',
              helpertexts: '한글로 입력해주세요.',
              onchangeds: (name) {
                _name = name;
              },
            ),
            // SignUpTextField(
            //   validations: (String? val) {return _isValidname(val ?? '') ? null : "올바른 이름을 입력해주세요."},
            //   paddings: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
            //   keyboardtypes: TextInputType.text,
            //   hinttexts: '닉네임',
            //   helpertexts: '10글자 이내로 입력해주세요.',
            //   onchangeds: (nickname) {
            //     _nickname = nickname;
            //   },
            // ),
            SignUpTextField(
              validations: (String? val) {
                return _isValidBirth(val ?? '') ? null : "올바른 생년월일을 입력해주세요.";
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
                              ),
                            ),
                            leading: Radio<String>(
                              value: "M",
                              groupValue: _gender,
                              fillColor: MaterialStateColor.resolveWith(
                                      (states) => bColor),
                              onChanged: (String? value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                            ),
                          )),
                      Expanded(
                        child: ListTile(
                          title: const Text(
                            '여자',
                            style: TextStyle(
                              color: bColor,
                            ),
                          ),
                          leading: Radio<String>(
                            value: "F",
                            groupValue: _gender,
                            fillColor: MaterialStateColor.resolveWith(
                                    (states) => bColor),
                            onChanged: (String? value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SignUpTextField(
              validations: (String? val) {
                return _isValidPhone(val ?? '')
                    ? null
                    : "올바른 전화번호 형식으로 입력해주세요.";
              },
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.75.h, 7.5.w, 1.75.h),
              keyboardtypes: TextInputType.number,
              hinttexts: '전화번호',
              helpertexts: '숫자만 입력해주세요.',
              onchangeds: (number) {
                _phone = number;
              },
            ),
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.5.w, 1.75.h, 1.25.w, 1.75.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 1.25.w, 1.25.h),
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
                            style: TextStyle(color: b75Color),
                          )
                        : Text(
                            '(${this.postCode}) ${this.region}',
                            overflow: TextOverflow.ellipsis,
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
                                setState(() {
                                  this.postCode = result.postCode;
                                  this.region = result.address;
                                  this.latitude = result.latitude.toString();
                                  this.longitude = result.longitude.toString();
                                },);
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '우편번호',
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
                  if (_SignupKey.currentState!.validate()) {
                    _register();
                  }
                  ;
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: yColor,
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
