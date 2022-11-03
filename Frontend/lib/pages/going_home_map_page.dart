import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/main.dart';
import 'package:sizer/sizer.dart';

import '../components/safearea/going_home_map.dart';

class GoingHomeMapPage extends StatefulWidget {
  const GoingHomeMapPage(this.homeLat, this.homeLon, this.accessCode,
      this.profileImage, this.name, this.phone,
      {Key? key})
      : super(key: key);
  final homeLat;
  final homeLon;
  final accessCode;
  final profileImage;
  final name;
  final phone;

  @override
  State<GoingHomeMapPage> createState() => _GoingHomeMapPageState();
}

class _GoingHomeMapPageState extends State<GoingHomeMapPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('WatchOuT',
              style: TextStyle(color: yColor, fontSize: 20.sp)),
          centerTitle: true,
          backgroundColor: nColor,
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                AuthService().signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()),
                    (route) => false);
              },
            )
          ],
        ),
        body: GoingHomeMap(widget.homeLat, widget.homeLon, widget.accessCode,
            widget.profileImage, widget.name, widget.phone));
  }
}
