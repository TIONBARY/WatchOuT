import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
import 'package:homealone/constants.dart';
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

  String? _name = '';
  String? _nickname = '';
  String? _gender = '';
  String? _phone = '';
  String? _age = '';
  String? _region = '';

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
    print("nickname은 ${_nickname}");
    db.collection("user").doc("${loggedUser!.uid}").update({
      "nickname": _nickname,
      "name": _name,
      "gender": _gender,
      "age": _age,
      "phone": _phone,
      "region": _region,
      "activated": true,
    });
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
              color: n75Color,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 4.h, 0, 0),
                child: Image(
                  image: AssetImage('assets/WatchOuT_Logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SignUpTextField(
              paddings: EdgeInsets.fromLTRB(7.5.w, 2.5.h, 7.5.w, 1.25.h),
              keyboardtypes: TextInputType.text,
              hinttexts: '이름',
              helpertexts: '한글로 입력해주세요.',
              onchangeds: (name) {
                _name = name;
              },
            ),
            SignUpTextField(
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
              keyboardtypes: TextInputType.text,
              hinttexts: '닉네임',
              helpertexts: '10글자 이내로 입력해주세요.',
              onchangeds: (nickname) {
                _nickname = nickname;
              },
            ),
            SignUpTextField(
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
              keyboardtypes: TextInputType.number,
              hinttexts: '생년월일',
              helpertexts: 'YYMMDD 형식으로 입력해주세요.',
              onchangeds: (age) {
                _age = age;
              },
            ),
            Container(
                padding: EdgeInsets.fromLTRB(7.5.w, 0, 7.5.w, 0),
                child: Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: ListTile(
                        title: const Text(
                          '남자',
                          style: TextStyle(
                            color: nColor,
                          ),
                        ),
                        leading: Radio<String>(
                          value: "M",
                          groupValue: _gender,
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => nColor),
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
                            color: nColor,
                          ),
                        ),
                        leading: Radio<String>(
                          value: "F",
                          groupValue: _gender,
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => nColor),
                          onChanged: (String? value) {
                            setState(() {
                              _gender = value;
                            });
                          },
                        ),
                      )),
                    ],
                  )
                ])),
            SignUpTextField(
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
              keyboardtypes: TextInputType.number,
              hinttexts: '전화번호',
              helpertexts: '숫자만 입력해주세요.',
              onchangeds: (number) {
                _phone = number;
              },
            ),
            SignUpTextField(
              paddings: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
              keyboardtypes: TextInputType.number,
              hinttexts: '지역',
              helpertexts: '우편번호(5글자)로 입력해주세요.',
              onchangeds: (region) {
                _region = region;
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: nColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {
                  _register();
                  Navigator.pop(context);
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
