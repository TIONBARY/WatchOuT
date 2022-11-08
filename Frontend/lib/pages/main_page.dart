import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      body: Container(
        child: Column(
          children: [
            // Flexible(
            //   child: ProfileBar(),
            //   flex: 2,
            // ),
            Flexible(
              child: Carousel(),
              flex: 4,
            ),
            Flexible(
              child: MainButtonUp(),
              flex: 3,
            ),
            Flexible(
              child: MainButtonDown(),
              flex: 3,
            ),
            // Flexible(
            //   child: Carousel(),
            //   flex: 4,
            // ),
          ],
        ),
      ),
    );
  }
}
