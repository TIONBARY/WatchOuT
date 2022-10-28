import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/googleLogin/loading_page.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<SwitchBools>(create: (_) => SwitchBools()),
      ChangeNotifierProvider<MyUserInfo>(create: (_) => MyUserInfo()),
      ChangeNotifierProvider<HeartRateProvider>(
          create: (_) => HeartRateProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final watch = WatchConnectivity();
    // bool reachable = false;
    double heartRateBPM = 0.0;
    // watch.isReachable.then((value) => setState(() => {reachable = value}));

    watch.receivedApplicationContexts.then((value) =>
        setState(() => {heartRateBPM = double.parse(value.last.values.last)}));

    watch.contextStream.listen((e) => setState(() {
          // debugPrint("심박수 리스너 내부");
          // debugPrint(reachable.toString());
          heartRateBPM = double.parse(e.values.last);
          Provider.of<HeartRateProvider>(context, listen: false).heartRate =
              heartRateBPM;
          debugPrint("BPM 심박수 $heartRateBPM");
          Map<String, String> msg = HashMap<String, String>();
          msg.addEntries({"HEART_RATE": heartRateBPM.toString()}.entries);
          watch.sendMessage(msg);
        }));
    // HeartRateProvider().changeHeartRate(heartRateBPM);
    // debugPrint("일단 심박수 $heartRateBPM");
    initBackground();
  }

  @override
  Widget build(BuildContext context) {
    _permission();
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WatchOut',
        theme: ThemeData(
          fontFamily: 'HanSan',
          primarySwatch: Colors.blue,
          primaryColor: Colors.white,
          accentColor: Colors.black,
        ),
        home: const HomePage(),
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchOut',
      theme: ThemeData(
        fontFamily: 'HanSan',
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
      home: FutureBuilder(
        future: test(),
        builder: (context, snapshot) {
          var fb = snapshot.data!["FB"];
          if (snapshot.hasError) {
            return LoadingPage();
            // 에러페이지 없어서 대충 로딩페이지 재활용
          }
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            // Widget tmp = Container(
            //   child: Text("hi"),
            // );
            // AuthService().test().then((value) => tmp = value);
            return snapshot.data!["tmp"];
            // AuthService().handleAuthState();
          }
          // Otherwise, show something whilst waiting for initialization to complete
          return LoadingPage();
        },
      ),
    );
  }
}

Future<Map<String, dynamic>> test() async {
  Map<String, dynamic> tmp = new Map();
  // Widget widgetTmp = Container(
  //   child: Text("실패~"),
  // );

  tmp.addEntries({"FB": await Firebase.initializeApp()}.entries);
  tmp.addEntries({"tmp": await AuthService().test()}.entries);
  return tmp;
}

void _permission() async {
  var requestStatus = await Permission.location.request();
  // var requestStatus = await Permission.locationAlways.request();

  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
  }

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.locationAlways,
    Permission.manageExternalStorage,
    Permission.storage,
  ].request();
  print(statuses[Permission.location]);

  var status = await Permission.location.status;
  if (requestStatus.isGranted && status.isLimited) {
    // isLimited - 제한적 동의 (ios 14 < )
    // 요청 동의됨
    print("isGranted");
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // 요청 동의 + gps 켜짐
    } else {
      // 요청 동의 + gps 꺼짐
      print("serviceStatusIsDisabled");
    }
  } else if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
    // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
    print("isPermanentlyDenied");
    openAppSettings();
  } else if (status.isRestricted) {
    // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
    print("isRestricted");
    openAppSettings();
  } else if (status.isDenied) {
    // 권한 요청 거절
    print("isDenied");
  }
  print("requestStatus ${requestStatus.name}");
  print("status ${status.name}");
}

void initBackground() async {
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "워치 아웃",
    notificationText: "워치아웃이 백그라운드에서 실행중입니다.",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  bool success =
      await FlutterBackground.initialize(androidConfig: androidConfig);
  bool hasPermissions = await FlutterBackground.hasPermissions;
  if (hasPermissions) {
    success = await FlutterBackground.enableBackgroundExecution();
  }
}
