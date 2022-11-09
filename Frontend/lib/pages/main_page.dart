import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              flex: 1,
            ),
            // Flexible(
            //   child: MainButtonUp(),
            //   flex: 1,
            // ),
            // Flexible(
            //   child: MainButtonDown(),
            //   flex: 1,
            // ),
          ],
        ),
      ),
    );
  }
}
