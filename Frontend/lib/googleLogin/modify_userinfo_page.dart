import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/modify_userinfo.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class ModifyUserInfoPage extends StatefulWidget {
  const ModifyUserInfoPage({Key? key}) : super(key: key);

  @override
  State<ModifyUserInfoPage> createState() => _ModifyUserInfoPageState();
}

class _ModifyUserInfoPageState extends State<ModifyUserInfoPage> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  User? loggedUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Map userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print("userInfoPage.dart에서 user 정보를 잘 받아왔습니다.");
      }
    } catch (e) {
      print("userInfoPage.dart에서 유저 정보를 받아오지 못했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        centerTitle: true,
        title: Text(
          "회원정보 수정",
          style: TextStyle(
            color: yColor,
            fontSize: 15.sp,
          ),
        ),
        backgroundColor: bColor,
      ),
      body: ModifyUserInfo(),
    );
  }

  Widget _handleCurentScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final userInfoRef = db
            .collection("user")
            .where("googleUID", isEqualTo: "${loggedUser?.uid}");
        var userInfo;
        userInfoRef.get().then((value) => userInfo = value);
        //유저 상세 정보 저장해주기
        return Text("유저 상세 데이터 저장");
      },
    );
  }
}
