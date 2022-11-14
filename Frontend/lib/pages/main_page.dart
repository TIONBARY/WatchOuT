import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/main/guide_bar.dart';
import 'package:homealone/components/main/main_button_down.dart';
import 'package:homealone/components/main/main_button_up.dart';

import '../components/main/carousel.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _authentication = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GuideBar(),
          Carousel(),
          Expanded(
            flex: 1,
            child: MainButtonDown(),
          ),
          Expanded(
            flex: 1,
            child: MainButtonUp(),
          ),
        ],
      ),
    );
  }
}
