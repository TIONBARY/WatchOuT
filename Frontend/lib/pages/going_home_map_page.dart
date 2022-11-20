import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
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
          backgroundColor: bColor,
        ),
        body: GoingHomeMap(widget.homeLat, widget.homeLon, widget.accessCode,
            widget.profileImage, widget.name, widget.phone));
  }
}
