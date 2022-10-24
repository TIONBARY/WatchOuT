import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/googleLogin/loading_page.dart';

import 'googleLogin/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WatchOut',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    ScreenUtil.init(context);
    return ScreenUtilInit(
      designSize: Size(deviceWidth, deviceHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'WatchOut',
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
      },
    );
  }
}
