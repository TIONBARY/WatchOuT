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
  String address = '';
  String latitude = '-';
  String longitude = '-';
  String kakaoLatitude = '-';
  String kakaoLongitude = '-';

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
      "region": '${this.address} (${this.postCode})',
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
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 1.25.w, 1.25.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 1.25.w, 1.25.h),
                    width: 62.5.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 1.sp,
                          color: n25Color,
                        )),
                    child: (this.postCode.isEmpty && this.address.isEmpty)
                        ? Text(
                            '주소',
                            style: TextStyle(color: n75Color),
                          )
                        : Text(
                            '(${this.postCode}) ${this.address}',
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
                        backgroundColor: nColor,
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
                                  this.address = result.address;
                                  this.latitude = result.latitude.toString();
                                  this.longitude = result.longitude.toString();
                                });
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
            // Container(
            //   padding: EdgeInsets.all(40.0),
            //   child: Column(
            //     children: [
            //       Text(
            //           'latitude: ${this.latitude} / longitude: ${this.longitude}'),
            //     ],
            //   ),
            // ),
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
