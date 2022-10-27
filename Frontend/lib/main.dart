import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:homealone/googleLogin/loading_page.dart';

import 'firebase_options.dart';
import 'googleLogin/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchOuT main.dart page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadingPage();
            // 에러페이지 없어서 대충 로딩페이지 재활용
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return RootPage();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return LoadingPage();
        },
      ),
    );
  }
}
