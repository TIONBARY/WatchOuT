import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../googleLogin/login_page.dart';
import '../../googleLogin/tab_bar_page.dart';

class AuthService {
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
    return documentData;
  }

  //Determine if the user is authenticated.
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            print("로그인 되었습니다.");
            return TabNavBar(FirebaseAuth.instance.currentUser!);
          } else {
            print("로그아웃 되었습니다.");
            return LoginPage();
          }
        });
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
