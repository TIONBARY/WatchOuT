import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/safearea/going_home_map.dart';

class GoingHomeMapPage extends StatefulWidget {
  const GoingHomeMapPage(this.homeLat, this.homeLon, this.accessCode,
      {Key? key})
      : super(key: key);
  final homeLat;
  final homeLon;
  final accessCode;

  @override
  State<GoingHomeMapPage> createState() => _GoingHomeMapPageState();
}

class _GoingHomeMapPageState extends State<GoingHomeMapPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: GoingHomeMap(widget.homeLat, widget.homeLon, widget.accessCode));
  }
}
