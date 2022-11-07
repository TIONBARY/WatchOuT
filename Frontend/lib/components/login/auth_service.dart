import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:provider/provider.dart';

import '../../googleLogin/login_page.dart';
import '../../googleLogin/sign_up_page.dart';
import '../../googleLogin/tab_bar_page.dart';
import '../../providers/user_provider.dart';
import 'user_service.dart';

class AuthService {
  FirebaseAuth authentication = FirebaseAuth.instance;

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
          UserService().registerBasicUserInfo();
        } else if (userDocs!["activated"]) {
          Provider.of<MyUserInfo>(context, listen: false).setUser(userDocs);
          return getFirstResponder();
        } else {
          UserService().registerBasicUserInfo();
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
