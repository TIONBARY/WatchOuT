import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SafeAreaPage extends StatefulWidget {
  const SafeAreaPage({Key? key}) : super(key: key);

  @override
  State<SafeAreaPage> createState() => _SafeAreaPageState();
}

class _SafeAreaPageState extends State<SafeAreaPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
