import 'package:encrypt/encrypt.dart' as en;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/set/circular_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class CircularMenu extends StatefulWidget {
  @override
  _CircularMenuState createState() => _CircularMenuState();
}

class _CircularMenuState extends State<CircularMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  late Animation rotationAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 2.w,
          bottom: 1.h,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              IgnorePointer(
                child: Container(
                  color: Colors.transparent,
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(getRadiansFromDegree(255),
                    degOneTranslationAnimation.value * 75),
                child: Transform(
                  transform: Matrix4.rotationZ(
                      getRadiansFromDegree(rotationAnimation.value))
                    ..scale(degOneTranslationAnimation.value),
                  alignment: Alignment.center,
                  child: CircularButton(
                    heights: 50,
                    widths: 50,
                    colors: nColor,
                    icons: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    onpresseds: () {
                      invite();
                    },
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(getRadiansFromDegree(195),
                    degThreeTranslationAnimation.value * 75),
                child: Transform(
                  transform: Matrix4.rotationZ(
                      getRadiansFromDegree(rotationAnimation.value))
                    ..scale(degThreeTranslationAnimation.value),
                  alignment: Alignment.center,
                  child: CircularButton(
                    heights: 50,
                    widths: 50,
                    colors: yColor,
                    icons: Icon(
                      Icons.exit_to_app_sharp,
                      color: Colors.white,
                    ),
                    onpresseds: () {
                      AuthService().signOut();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => HomePage(),
                          ),
                          (route) => false);
                      SharedPreferences.getInstance().then(
                        (prefs) async => {
                          await prefs.remove('username'),
                          await prefs.remove('userphone'),
                          await prefs.remove('contactlist'),
                        },
                      );
                    },
                  ),
                ),
              ),
              Transform(
                transform: Matrix4.rotationZ(
                    getRadiansFromDegree(rotationAnimation.value)),
                alignment: Alignment.center,
                child: CircularButton(
                  heights: 50,
                  widths: 50,
                  colors: bColor,
                  icons: Icon(
                    Icons.menu,
                    color: yColor,
                  ),
                  onpresseds: () {
                    if (animationController.isCompleted) {
                      animationController.reverse();
                    } else {
                      animationController.forward();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void invite() async {
    User? user = FirebaseAuth.instance.currentUser;
    // 하루 뒤에 만료하는 코드
    DateTime expDate = DateTime.now().add(Duration(days: 1));
    String infoCode = "${expDate.toIso8601String()},${user?.uid}";
    // debugPrint(expDate.toIso8601String());

    //암호화 하기

    await dotenv.load();
    String inviteRandomKey = dotenv.get('inviteRandomKey');
    final key = en.Key.fromUtf8(inviteRandomKey);
    final iv = en.IV.fromLength(16);
    final encrypter = en.Encrypter(en.AES(key));
    String encryptedCode = encrypter.encrypt(infoCode, iv: iv).base64;
    debugPrint('암호화 된값: $encryptedCode');
    debugPrint(infoCode);
    debugPrint(encryptedCode);

    // String inviteUrl =
    //     "https://www.homelaone.kr/action?inviteKey=$encryptedCode";
    String inviteUrl =
        "https://homelaone.page.link/?link=https://www.homelaone.kr/action?inviteKey=$encryptedCode&apn=com.ssafy.homealone&afl=https://play.google.com/store/apps/details?id=com.ssafy.homealone";

    Share.share('지금 당장 [워치아웃] 앱을 설치하세요!\n$inviteUrl');
  }
}
