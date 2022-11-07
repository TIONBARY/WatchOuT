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
import 'package:homealone/pages/emergency_manual_page.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:sizer/sizer.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

HeartRateProvider heartRateProvider = HeartRateProvider();
final isCheck = IsCheck.instance;

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

// void initQuickActions() {
//   final QuickActions _quickActions = new QuickActions();
//   _quickActions.initialize((navigateRoute);
//   _quickActions.setShortcutItems([
//     ShortcutItem(type: "SOS", localizedTitle: "SOS"),
//     ShortcutItem(type: "SafeHome", localizedTitle: "안심귀가"),
//     ShortcutItem(type: "성범죄자 알림e", localizedTitle: "알림e"),
//     ShortcutItem(type: "SafeZone", localizedTitle: "안전구역"),
//   ]);
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    heartRateProvider = Provider.of<HeartRateProvider>(context, listen: false);
    initializeService();
    initUsage();
    // initQuickActions();
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    quickActions.setShortcutItems([
      ShortcutItem(type: "SafeZone", localizedTitle: "안전 구역", icon: 'safezone'),
      ShortcutItem(
          type: "EmergencyManual", localizedTitle: "응급상황 메뉴얼", icon: 'manual'),
    ]);
    quickActions.initialize((type) {
      if (type == "SafeZone") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SafeAreaCCTVMapPage()));
      } else if (type == "EmergencyManual") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => EmergencyManual()));
      }
    });
  }

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
      "WatchOuT에서 \n'안전 지도' 및 '보호자 공유' \n등의 기능을 사용할 수 있도록 \n'위치 권한'을 허용해 주세요.");
  // askPermission(
  //     context, Permission.sms, "워치아웃에서 SOS 기능을 사용할 수 있도록 SMS 권한을 허용해 주세요.");
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

  Timer.periodic(
    Duration(seconds: 10), //디버그용으로 10초로 해논건데 실배포할때는 24시간으로 바꿔야함
    (timer) {
      Future<int> count = initUsage();
      count.then((value) {
        print('24시간 이내에 사용한 앱 갯수 : $value');
        if (value == 0)
          print('비상!!!! 초비상!!!!');
        else
          print('24시간 이내 사용 감지');
      }).catchError((error) {
        print(error);
      });
    },
  );
}

Future<int> initUsage() async {
  int count = 0;

  UsageStats.grantUsagePermission();

  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(Duration(days: 1));

  List<UsageInfo> t = await UsageStats.queryUsageStats(startDate, endDate);
  List<ConfigurationInfo> t2 =
      await UsageStats.queryConfiguration(startDate, endDate);
  List<EventInfo> t3 = await UsageStats.queryEventStats(startDate, endDate);

  // for (var i in t) {
  //   DateTime lastUsed =
  //       DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeUsed!)).toUtc();
  //   if (lastUsed.isAfter(startDate)) count++;
  // }

  for (var i in t2) {
    DateTime lastUsed =
        DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeActive!))
            .toUtc();
    if (lastUsed.isAfter(startDate)) count++;
    print('================${i.configuration}');
    print('----------------${i.totalTimeActive}');
    print('-=-=-=-=-=-=-=-=${i.activationCount}');
  }

  // for (var i in t3) {
  //   DateTime lastUsed =
  //       DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastEventTime!))
  //           .toUtc();
  //   if (lastUsed.isAfter(startDate)) count++;
  //   print('=============${i.count}');
  //   print('-------------${i.eventType}');
  //   print('=-=-=-=-=-=-=${i.totalTime}');
  // }

  return count;
}

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
