import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up_page.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: SignUpForm(),
              ),
            ],
          ),
        ),
      ),
      // SignUpForm(),
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
