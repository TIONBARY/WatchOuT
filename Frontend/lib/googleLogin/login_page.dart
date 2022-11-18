import 'dart:async';

import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: bColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'WatchOuT',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                  color: yColor,
                  fontFamily: 'HanSan',
                ),
              ),
              Container(
                margin: EdgeInsets.all(50.0),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: AnimatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          "assets/icons/Google_Logo.png",
                          height: 2.5.h,
                        ),
                      ),
                      Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: b50Color,
                          fontFamily: 'HanSan',
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    _handleSignIn().then(
                      (user) {
                        debugPrint(user.toString());
                      },
                    );
                  },
                  type: PredefinedThemes.light,
                  height: 50,
                  width: 250,
                  isOutline: true,
                  darkShadow: false,
                  // shadowHeightBottom: 4,
                  // shadowHeightLeft: 4,
                  borderRadius: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<User> _handleSignIn() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    User? user = (await _auth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken)))
        .user;
    debugPrint("signed in ${user!.displayName!}");
    return user!;
  }
}
