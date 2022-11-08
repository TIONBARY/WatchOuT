import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/safearea/safe_area_cctv_map.dart';

class SafeAreaCCTVMapPage extends StatefulWidget {
  const SafeAreaCCTVMapPage({Key? key}) : super(key: key);

  @override
  State<SafeAreaCCTVMapPage> createState() => _SafeAreaCCTVMapPageState();
}

class _SafeAreaCCTVMapPageState extends State<SafeAreaCCTVMapPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: SafeAreaCCTVMap());
  }
}
