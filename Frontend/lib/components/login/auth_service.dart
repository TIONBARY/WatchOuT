import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:provider/provider.dart';

import '../../googleLogin/login_page.dart';
import '../../googleLogin/sign_up_page.dart';
import '../../googleLogin/tab_bar_page.dart';
import '../../providers/user_provider.dart';

class AuthService {
  FirebaseAuth authentication = FirebaseAuth.instance;

  Future<bool> activated() async {
    FirebaseAuth _authentication = FirebaseAuth.instance;
    User? currentUser = _authentication.currentUser;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc("${currentUser?.uid}");
    Map<String, dynamic>? documentData;
    // Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null) print("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData?["activated"];
  }

  Future<Map<String, dynamic>?> userInfo() async {
    User? currentUser = authentication.currentUser;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc("${currentUser?.uid}");
    Map<String, dynamic>? documentData;
    // Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null) print("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData;
  }

  void registerBasicInfo() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = authentication.currentUser;
    db.collection("user").doc("${user?.uid}").set({
      "googleUID": "${user?.uid}",
      "profileImage": "${user?.photoURL}",
      "phone": "01012345678",
      "birth": "12",
      "blocked": false,
      "activated": false,
      "region": "12345", //(시군구번호)
      "nickname": "구의동호랑이",
      "name": "홍길동",
      "gender": "M",
      "hide": false,
      "latitude": "",
      "longitude": "",
    });
  }

  void registerFirstResponder(String name, String number) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("firstResponder")
        .doc(name)
        .set({"number": number});
  }

  getFirstResponder() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("user")
          .doc("${FirebaseAuth.instance.currentUser?.uid}")
          .collection("firstResponder")
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final phoneDocs = snapshot.data!.docs;
        if (snapshot.hasData) {
          for (int i = 0; i < phoneDocs.length; i++) {
            Provider.of<ContactInfo>(context, listen: false)
                .addResponder(phoneDocs[i].id, phoneDocs[i]["number"]);
            print("phoneDocs의 값은 다음과 같다 : ${phoneDocs[i].id}");
          }
        }
        return TabNavBar();
      },
    );
  }

  //Determine if the user is authenticated.
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            print("구글 계정이 확인되었습니다.");
            print("${FirebaseAuth.instance.currentUser!.uid}");
            return handleDetailState(FirebaseAuth.instance.currentUser!.uid);
          } else {
            print("로그아웃 되었습니다.");
            return LoginPage();
          }
        });
  }

  handleDetailState(String googleUID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("user")
          .doc("${googleUID}")
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        ;
        final userDocs = snapshot.data!.data();
        if (userDocs == null) {
          registerBasicInfo();
        } else if (userDocs!["activated"]) {
          print("activaetd");
          Provider.of<MyUserInfo>(context, listen: false).setUser(userDocs);
          // getFirstResponder();
          return getFirstResponder();
        } else {
          print("non activated");
          registerBasicInfo();
          return SignUpPage();
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
