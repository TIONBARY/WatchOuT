import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up.dart';
import 'package:homealone/pages/main_page.dart';

class userInfoPage extends StatefulWidget {
  const userInfoPage({Key? key}) : super(key: key);

  @override
  State<userInfoPage> createState() => _userInfoPageState();
}

class _userInfoPageState extends State<userInfoPage> {
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
    List<Map<String, dynamic>> userData;
    final userQuery = db
        .collection("user")
        .where("googleUID", isEqualTo: "${loggedUser!.uid}");
    userQuery.get().then(
      (value) {
        if (value.size > 0) {
          // 일단 데이터 받아서 저장하기
          userData = value.docs.map((e) => e.data()).toList();
          print("userData의 정보는 아래와 같다.");
          print(userData);
          if (userData[0]["activated"] == true) return MainPage();
          print("유저 상세 정보가 입력되지 않았습니다.");
        } else {
          // //db에 등록이 안되어있으므로
          db.collection("user").doc("${loggedUser!.uid}").set({
            "googleUID": loggedUser!.uid,
            "profileImage": loggedUser?.photoURL,
            "phone": loggedUser?.phoneNumber,
            "blocked": false,
            "activated": false,
            "region": "",
            "name": "",
            "gender": "",
            "hide": false
          }).then((documentSnapshot) => print("google 정보가 등록되었습니다."));
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 정보 입력'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app_sharp,
              color: Colors.white,
            ),
            onPressed: () {
              _authentication.signOut();
            },
          )
        ],
      ),
      body: SignUpForm(),
    );
    // }
  }

  Widget _handleCurrentScreen() {
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
