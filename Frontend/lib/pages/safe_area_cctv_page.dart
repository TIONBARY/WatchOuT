import 'package:flutter/material.dart';
import 'package:homealone/components/safearea/safe_area_cctv_map.dart';

class SafeAreaCCTVMapPage extends StatefulWidget {
  const SafeAreaCCTVMapPage({Key? key}) : super(key: key);

  @override
  State<SafeAreaCCTVMapPage> createState() => _SafeAreaCCTVMapPageState();
}

class _SafeAreaCCTVMapPageState extends State<SafeAreaCCTVMapPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: SafeAreaCCTVMap());
  }
}
