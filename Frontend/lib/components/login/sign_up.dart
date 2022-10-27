import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/pages/main_page.dart';

import 'custom_dialog.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignUpForm> {
  final _SignupFormKey = GlobalKey<FormState>();

  String? _name = '';
  String? _password = '';
  String? _nickname = '';
  String? _gender = '';
  String? _phone = '';
  String? _email = '';
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
    _SignupFormKey.currentState!.save();
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
        key: _SignupFormKey,
        child: ListView(
          children: [
            Container(
              // width: 100,
              height: 200,
              color: Colors.red,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "닉네임",
                    helperText: "한글만 입력 가능해요",
                    hintText: "닉네임을 입력해주세요.",
                    icon: Icon(Icons.android),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(3)),
                onChanged: (nickname) {
                  _nickname = nickname;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "이름",
                    helperText: "한글만 입력 가능해요",
                    hintText: "닉네임을 입력해주세요.",
                    icon: Icon(Icons.android),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(3)),
                onChanged: (name) {
                  _name = name;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "성별",
                    helperText: "한글만 입력 가능해요",
                    hintText: "닉네임을 입력해주세요.",
                    icon: Icon(Icons.android),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(3)),
                onChanged: (gender) {
                  _gender = gender;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "나이",
                    helperText: "한글만 입력 가능해요",
                    hintText: "닉네임을 입력해주세요.",
                    icon: Icon(Icons.android),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(3)),
                onChanged: (age) {
                  _age = age;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "전화번호",
                    helperText: "한글만 입력 가능해요",
                    hintText: "닉네임을 입력해주세요.",
                    icon: Icon(Icons.android),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(3)),
                onChanged: (number) {
                  _phone = number;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "지역",
                    helperText: "한글만 입력 가능해요",
                    hintText: "닉네임을 입력해주세요.",
                    icon: Icon(Icons.android),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(3)),
                onChanged: (region) {
                  _region = region;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  _register();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                            "회원가입에 성공했습니다.", (context) => MainPage());
                      });
                },
                child: Text('회원가입'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
