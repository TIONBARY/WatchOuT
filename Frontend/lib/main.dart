import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homealone/components/dialog/permission_rationale_dialog.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/singleton/is_check.dart';
import 'package:homealone/googleLogin/loading_page.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

HeartRateProvider heartRateProvider = HeartRateProvider();
final isCheck = IsCheck.instance;
DateTime recent = DateTime.now();
String recentPackage = 'android';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactInfo>(create: (_) => ContactInfo()),
        ChangeNotifierProvider<SwitchBools>(create: (_) => SwitchBools()),
        ChangeNotifierProvider<MyUserInfo>(create: (_) => MyUserInfo()),
        ChangeNotifierProvider<HeartRateProvider>(
            create: (_) => HeartRateProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<EventUsageInfo> events = [];
  Map<String?, NetworkInfo?> _netInfoMap = Map();

  @override
  void initState() {
    super.initState();
    heartRateProvider = Provider.of<HeartRateProvider>(context, listen: false);
    initializeService();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WatchOuT',
          theme: ThemeData(
            fontFamily: 'HanSan',
            primarySwatch: Colors.blue,
            primaryColor: Colors.white,
            accentColor: Colors.black,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchOuT',
      theme: ThemeData(
        fontFamily: 'HanSan',
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          _permission(context);
          if (snapshot.hasError) {
            return LoadingPage();
          }
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            print("handleAuthstate로 넘어감");
            return AuthService().handleAuthState();
          }
          // Otherwise, show something whilst waiting for initialization to complete
          return LoadingPage();
        },
      ),
    );
  }
}

void askPermission(
    BuildContext context, Permission permission, String message) async {
  if (await permission.isGranted) {
    return;
  }
  Future.microtask(() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PermissionRationaleDialog(permission, message))));
}

bool permissionOnce = false;
void _permission(BuildContext context) async {
  if (permissionOnce) {
    return;
  }
  permissionOnce = true;
  askPermission(context, Permission.location,
      "워치아웃에서 안전 지도, 보호자 공유 등의 기능을 사용할 수 있도록 위치 권한을 허용해 주세요.");
  askPermission(
      context, Permission.sms, "워치아웃에서 SOS 기능을 사용할 수 있도록 SMS 권한을 허용해 주세요.");
}

// void _permission() async {
//   var requestStatus = await Permission.location.request();
//   // var requestStatus = await Permission.locationAlways.request();
//
//   if (await Permission.contacts.request().isGranted) {
//     // Either the permission was already granted before or the user just granted it.
//   }
// // You can request multiple permissions at once.
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.locationAlways,
//     Permission.manageExternalStorage,
//     Permission.storage,
//   ].request();
//   print(statuses[Permission.location]);
//
//   var status = await Permission.location.status;
//   if (requestStatus.isGranted && status.isLimited) {
//     // isLimited - 제한적 동의 (ios 14 < )
//     // 요청 동의됨
//     print("isGranted");
//     if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
//       // 요청 동의 + gps 켜짐
//     } else {
//       // 요청 동의 + gps 꺼짐
//       print("serviceStatusIsDisabled");
//     }
//   } else if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
//     // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
//     print("isPermanentlyDenied");
//     openAppSettings();
//   } else if (status.isRestricted) {
//     // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
//     print("isRestricted");
//     openAppSettings();
//   } else if (status.isDenied) {
//     // 권한 요청 거절
//     print("isDenied");
//   }
//   print("requestStatus ${requestStatus.name}");
//   print("status ${status.name}");
// }

// this will be used as notification channel id
const notificationChannelId = 'emergency_notification';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 119;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    '응급 상황 발생', // title
    description: '위기 상황 발생 시, 등록된 연락처로 알림을 전송하고 결과를 보여줍니다.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: false,

      notificationChannelId:
          notificationChannelId, // this must match with notification channel you created above.
      initialNotificationTitle: '워치 아웃',
      initialNotificationContent: '초기화 진행중...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    onStartWatch(service, flutterLocalNotificationsPlugin);
  }

  // Timer.periodic(
  //   Duration(seconds: 10),
  //   (timer) {
  //     initUsage();
  //   },
  // );

  // Timer.periodic(
  //   Duration(minutes: 1),
  //   (timer) {
  //     isCheck.initCheck();
  //     print('출석 초기화${isCheck.check}');
  //   },
  // );
  //
  // Timer.periodic(
  //   Duration(seconds: 10),
  //   (timer) {
  //     print('현재 출석 상태${isCheck.check}');
  //     print('메인다트${isCheck.hashCode}');
  //   },
  // );
}

// Future<void> initUsage() async {
//   try {
//     UsageStats.grantUsagePermission();
//
//     DateTime endDate = new DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 1));
//
//     List<EventUsageInfo> queryEvents =
//         await UsageStats.queryEvents(startDate, endDate);
//     List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(
//       startDate,
//       endDate,
//       networkType: NetworkType.all,
//     );
//
//     Map<String?, NetworkInfo?> netInfoMap = Map.fromIterable(networkInfos,
//         key: (v) => v.packageName, value: (v) => v);
//
//     List<UsageInfo> t = await UsageStats.queryUsageStats(startDate, endDate);
//
//     for (var i in t) {
//       if ((i.packageName?.compareTo(recentPackage)) == 0) {
//         DateTime newRecent =
//             DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeUsed!))
//                 .toUtc();
//         print('현재시간 : ${recent}');
//         print(i.packageName);
//         print('패지키 마지막 사용 시간 : ${newRecent}');
//
//         int time_diff = ((recent.year - newRecent.year) * 8760) +
//             ((recent.month - newRecent.month) * 730) +
//             ((recent.day - newRecent.day) * 24) +
//             (recent.hour - newRecent.hour);
//
//         print('두 시간 차 : ${time_diff}');
//       }
//     }
//   } catch (err) {
//     print(err);
//   }
// }

void onStartWatch(ServiceInstance service,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  final watch = WatchConnectivity();
  double heartRateBPM = 0.0;
  Map<String, String> msg = HashMap<String, String>();

  watch.receivedApplicationContexts
      .then((value) => heartRateBPM = double.parse(value.last.values.last));
  watch.contextStream.listen((e) async => {
        heartRateBPM = double.parse(e.values.last),
        // Provider.of<HeartRateProvider>(context, listen: false)
        //     .heartRate = heartRateBPM,
        heartRateProvider.heartRate = heartRateBPM,
        debugPrint("BPM 심박수 $heartRateBPM"),
        msg.clear(),
        msg.addEntries({"HEART_RATE": heartRateBPM.toString()}.entries),
        watch.sendMessage(msg),
        // 임시 이상상황 감지 로직
        if (heartRateBPM >
                heartRateProvider.maxValue + heartRateProvider.gapValue ||
            heartRateProvider.minValue - heartRateProvider.gapValue >
                heartRateBPM)
          {
            flutterLocalNotificationsPlugin.show(
              notificationId,
              '워치아웃',
              '위기 상황 발생!!! $heartRateBPM ${DateTime.now()}',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                    notificationChannelId, '포그라운드 서비스',
                    icon: 'launch_background',
                    ongoing: false,
                    enableVibration: true,
                    fullScreenIntent: true,
                    importance: Importance.max,
                    autoCancel: true, // 알림 터치시 해제
                    timeoutAfter: 60 * 60 * 1000, // 1시간 뒤에는 자동으로 해제
                    actions: [
                      AndroidNotificationAction("ignore", "무시",
                          cancelNotification: true),
                      AndroidNotificationAction("open", "바로가기",
                          showsUserInterface: true, cancelNotification: true),
                    ]
                    // sound:
                    ),
              ),
            )
          }
      });
}
