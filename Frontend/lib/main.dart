import 'dart:async';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart' as fetch;
import 'package:firebase_core/firebase_core.dart';
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
import 'package:homealone/components/wear/local_notification.dart';
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
import 'package:workmanager/workmanager.dart' as wm;

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

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(fetch.HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    debugPrint("[백그라운드 헤드리스] Headless task timed-out: $taskId");
    fetch.BackgroundFetch.finish(taskId);
    return;
  }
  debugPrint('[백그라운드 헤드리스] Headless event received.');
  // Do your work here...
  initializeService();
  refreshUsage();

  fetch.BackgroundFetch.finish(taskId);
}

const fetchBackground = "fetchBackground";

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

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  fetch.BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    initializeService();
    initUsage();
    wm.Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    wm.Workmanager().registerPeriodicTask("1", fetchBackground,
        frequency: Duration(minutes: 15),
        initialDelay: Duration(seconds: 60),
        constraints: wm.Constraints(
            networkType: wm.NetworkType.not_required,
            requiresDeviceIdle: true));
    // debugPrint("메인꺼");
    // SharedPreferences.getInstance().then(
    //   (value) => {
    //     debugPrint(value.hashCode.toString()),
    //     debugPrint(value.getBool("useWearOS").toString())
    //   },
    // );
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await fetch.BackgroundFetch.configure(
        fetch.BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: fetch.NetworkType.NONE),
        (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      debugPrint("[백그라운드] Event received $taskId");
      setState(() {
        _events.insert(0, new DateTime.now());
      });
      initializeService();
      initUsage();
      wm.Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      wm.Workmanager().registerPeriodicTask("1", fetchBackground,
          frequency: Duration(minutes: 15),
          initialDelay: Duration(seconds: 60));
      // debugPrint("메인꺼");
      // SharedPreferences.getInstance().then(
      //   (value) => {
      //     debugPrint(value.hashCode.toString()),
      //     debugPrint(value.getBool("useWearOS").toString())
      //   },
      // );

      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      fetch.BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      debugPrint("[백그라운드] 시간초과 taskId: $taskId");
      fetch.BackgroundFetch.finish(taskId);
    });
    debugPrint('[백그라운드] configure success: $status');
    setState(() {
      _status = status;
    });
    // setState(() {
    //   status = status;
    // });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
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

Future<void> askPermission(
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
  await askPermission(context, Permission.locationAlways,
      "WatchOuT에서 \n백그라운드에서도 '안전 지도' 및 '보호자 공유' \n등의 기능을 사용할 수 있도록 \n'항상 허용'을 선택해 주세요.");
  await askPermission(context, Permission.location,
      "WatchOuT에서 \n'안전 지도' 및 '보호자 공유' \n등의 기능을 사용할 수 있도록 \n'위치 권한'을 허용해 주세요.");
  // if (await Permission.location.isDenied) {
  //   debugPrint("위치권한 거부");
  //   return;
  // }
  // askPermission(
  //     context, Permission.sms, "워치아웃에서 SOS 기능을 사용할 수 있도록 SMS 권한을 허용해 주세요.");
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences pref = await SharedPreferences.getInstance();
  Timer.periodic(
    Duration(hours: 1),
    (timer) {
      refreshUsage();
    },
  );

  if (service is AndroidServiceInstance) {
    onStartWatch(service, flutterLocalNotificationsPlugin, pref);
  }
}

void refreshUsage() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
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

void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        print("background task executed");
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        initLat = position.latitude;
        initLon = position.longitude;
        print("background location");
        print(initLat);
        print(initLon);
        break;
    }
    return Future.value(true);
  });
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
