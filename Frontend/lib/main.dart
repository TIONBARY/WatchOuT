import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/components/dialog/permission_rationale_dialog.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/main/main_button_up.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

final isCheck = IsCheck.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

ApiKakao apiKakao = ApiKakao();
ApiMessage apiMessage = ApiMessage();

String kakaoMapKey = "";

double initLat = 37.5013;
double initLon = 127.0396;

String message = "";
List<String> recipients = [];
String address = "";
bool messageIsSent = false;

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
StreamSubscription<Position>? _positionStreamSubscription;

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
    initializeService();
    initUsage();
    // debugPrint("메인꺼");
    // SharedPreferences.getInstance().then(
    //   (value) => {
    //     debugPrint(value.hashCode.toString()),
    //     debugPrint(value.getBool("useWearOS").toString())
    //   },
    // );

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
          navigatorKey: navigatorKey,
          routes: {'/emergency': (context) => MainButtonUp()},
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
            debugPrint("handleAuthstate로 넘어감");
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

double heartRate = 0.0;
double minValue = 0.0;
double maxValue = 300.0;

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
  InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"));
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: onReceiveNotificationResponse,
    onDidReceiveNotificationResponse: onReceiveNotificationResponse,
  );
  // 백그라운드에서 알림 수신시 대응할 함수
  // 포그라운드에서 알림 수신시 대응할 함수

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

void onReceiveNotificationResponse(NotificationResponse response) {
  // print(response.actionId);
  String value = response.actionId!;
  debugPrint("호출 $value");
  if (value == "expand") {
    updateHeartRate();
  }
}

void updateHeartRate() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  heartRate = pref.getDouble("heartRate")!;
  maxValue = pref.getDouble("maxValue")!;
  minValue = pref.getDouble("minValue")!;
  if (heartRate > maxValue) {
    maxValue += 5.0;
  } else if (heartRate < minValue) {
    minValue -= 5.0;
  }
  pref.setDouble("heartRate", heartRate);
  pref.setDouble("maxValue", maxValue);
  pref.setDouble("minValue", minValue);
  debugPrint("업데이트 결과 $maxValue, $minValue");
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences pref = await SharedPreferences.getInstance();
  LocationSettings locationSettings;
  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
        intervalDuration: const Duration(milliseconds: 500),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "백그라운드에서 위치정보를 받아오고 있습니다.",
          notificationTitle: "WatchOut이 백그라운드에서 실행중입니다.",
        ));
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.fitness,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: true,
      showBackgroundLocationIndicator: false,
    );
  } else {
    locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }
  _positionStreamSubscription = _geolocatorPlatform
      .getPositionStream(locationSettings: locationSettings)
      .listen((Position? position) {
    initLat = position!.latitude;
    initLon = position!.longitude;
  });
  Timer.periodic(
    Duration(hours: 1),
    (timer) {
      pref.reload();
      Future<int> count = initUsage();
      count.then((value) {
        print('24시간 이내에 사용한 앱 갯수 : $value');
        if (value == 0) {
          if (!messageIsSent)
            _getKakaoKey().then((response) => sendEmergencyMessage());
        } else {
          messageIsSent = false;
        }
      }).catchError((error) {
        print(error);
      });
    },
  );

  if (service is AndroidServiceInstance) {
    onStartWatch(service, flutterLocalNotificationsPlugin, pref);
  }
}

Future<int> initUsage() async {
  int count = 0;

  UsageStats.grantUsagePermission();

  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(Duration(days: 1));

  List<ConfigurationInfo> t2 =
      await UsageStats.queryConfiguration(startDate, endDate);
  for (var i in t2) {
    DateTime lastUsed =
        DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeActive!))
            .toUtc();
    if (lastUsed.isAfter(startDate)) count++;
  }

  return count;
}

void onStartWatch(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    SharedPreferences pref) {
  final watch = WatchConnectivity();
  // var newGap = "0.0";
  bool useWearOS = pref.getBool("useWearOS")!;
  Map<String, String> msg = HashMap<String, String>();
  watch.receivedApplicationContexts
      .then((value) => heartRate = double.parse(value.last.values.last));
  watch.contextStream.listen(
    (e) async => {
      heartRate = double.parse(e.values.last),
      useWearOS = pref.getBool("useWearOS")!,
      debugPrint("BPM 심박수 $heartRate"),
      msg.clear(),
      msg.addEntries({"HEART_RATE": heartRate.toString()}.entries),
      watch.sendMessage(msg),
      // 임시 이상상황 감지 로직
      if (useWearOS)
        {
          maxValue = pref.getDouble("maxValue")!,
          minValue = pref.getDouble("minValue")!,
          if (heartRate > maxValue || minValue > heartRate)
            {
              debugPrint("최대 최소 실시간: $maxValue, $minValue"),
              flutterLocalNotificationsPlugin.show(
                notificationId,
                '워치아웃',
                '위기 상황 발생!!! 심박수: ${heartRate.toInt()}',
                // payload: newGap,
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                      notificationChannelId, '포그라운드 서비스',
                      icon: 'launch_background',
                      ongoing: false,
                      enableVibration: true,
                      fullScreenIntent: false,
                      importance: Importance.max,
                      channelShowBadge: true,
                      channelDescription: "워치아웃 심박수 알림 채널",
                      autoCancel: true, // 알림 터치시 해제
                      timeoutAfter: 60 * 60 * 1000, // 1시간 뒤에는 자동으로 해제
                      actions: [
                        AndroidNotificationAction("ignore", "무시",
                            cancelNotification: true),
                        AndroidNotificationAction(
                          "expand",
                          "심박수 범위 확장",
                          showsUserInterface: false,
                          cancelNotification: true,
                          contextual: false,
                          // inputs: [
                          //   AndroidNotificationActionInput(
                          //     choices: ["-5","+5"],
                          //     allowFreeFormInput: false,
                          //   )
                          // ],
                        ),
                        AndroidNotificationAction("open", "바로가기",
                            showsUserInterface: true, cancelNotification: true),
                      ]
                      // playSound: ,
                      // sound:
                      ),
                ),
              ),
            },
        },
    },
  );
}

Future _getKakaoKey() async {
  await dotenv.load();
  kakaoMapKey = dotenv.get('kakaoMapAPIKey');
  return kakaoMapKey;
}

void _sendSMS(String message, List<String> recipients) async {
  await apiMessage.sendMessage(recipients, message);
}

Future<void> sendEmergencyMessage() async {
  await prepareMessage();
  if (recipients.isNotEmpty) {
    print(message);
    print(recipients);
    messageIsSent = true;
    _sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
  }
}

Future<void> getCurrentLocation() async {
  address =
      await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
}

Future<void> prepareMessage() async {
  await getCurrentLocation();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  message =
      "${preferences.getString('username')} 님이 24시간 동안 응답이 없습니다. 긴급 조치가 필요합니다. \n${preferences.getString('username')} 님의 번호 : ${preferences.getString('userphone')}\n현재 예상 위치 : ${address}\n이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
  List<String>? list = await preferences.getStringList('contactlist');
  if (list != null) {
    recipients = list!;
  }
}
