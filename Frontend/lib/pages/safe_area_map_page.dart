import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/safearea/safe_area_map.dart';

class SafeAreaMapPage extends StatefulWidget {
  const SafeAreaMapPage(this.name, {Key? key}) : super(key: key);

  final name;

  @override
  State<SafeAreaMapPage> createState() => _SafeAreaMapPageState();
}

class _SafeAreaMapPageState extends State<SafeAreaMapPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(title: Text('안전 지대 검색 - ' + widget.name)),
        body: SafeAreaMap(widget.name));
  }
}
