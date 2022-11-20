import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart' as fetch;
import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/wear/local_notification.dart';
import 'package:homealone/googleLogin/loading_page.dart';
import 'package:homealone/pages/emergency_manual_page.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:workmanager/workmanager.dart' as wm;

ApiKakao apiKakao = ApiKakao();
ApiMessage apiMessage = ApiMessage();

String kakaoMapKey = "";

double initLat = 37.5013;
double initLon = 127.0396;

String message = "";
List<String> recipients = [];
String address = "";
bool messageIsSent = false;

const locationCheck = "locationCheck";
const fetchBackground = "fetchBackground";

bool homecamRegistered = false;
String homecamAccessCode = "";
String homecamUrl = "";

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(fetch.HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    debugPrint("[백그라운드 헤드리스] Headless task timed-out: $taskId");
    fetch.BackgroundFetch.finish(taskId);
    return;
  }
  debugPrint('[백그라운드 헤드리스] Headless event received.');
  initializeNotificationService();
  refreshUsage();

  fetch.BackgroundFetch.finish(taskId);
}

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
  wm.Workmanager().cancelAll();
  wm.Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  wm.Workmanager().registerPeriodicTask(locationCheck, fetchBackground,
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 60),
      constraints: wm.Constraints(
          networkType: wm.NetworkType.not_required, requiresDeviceIdle: true));
  fetch.BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  initializeNotificationService();
  initUsage();
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
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WatchOuT',
          theme: ThemeData(
            fontFamily: 'WdcsB',
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
        fontFamily: 'WdcsB',
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
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

// release 모드에서 동작하기 위해 필요
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    onStartWatch(flutterLocalNotificationsPlugin);
  }
}

@pragma('vm:entry-point')
Future<void> refreshUsage() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.reload();
  Future<int> count = initUsage();
  if (!pref.getBool("useScreen")!) {
    wm.Workmanager().cancelByUniqueName(locationCheck);
    return;
  }
  // await sendEmergencyMessage();
  count.then((value) async {
    debugPrint('24시간 이내에 사용한 앱 갯수 : $value');
    if (value == 0) {
      if (!messageIsSent) {
        await sendEmergencyMessage();
      }
    } else {
      messageIsSent = false;
    }
  }).catchError((error) {
    debugPrint(error);
  });
}

@pragma('vm:entry-point')
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

@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        initLat = position.latitude;
        initLon = position.longitude;
        await refreshUsage();
        break;
    }
    return true;
  });
}

@pragma('vm:entry-point')
Future<void> sendSMS(String message, List<String> recipients) async {
  // String result = await MethodChannel('com.ssafy.homealone/channel')
  //     .invokeMethod('sendTextMessage', {
  //   'message': message,
  //   'recipients': recipients
  // }).catchError((error) => print(error));
  for (String recipient in recipients) {
    SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: recipient, message: message);
    if (result == SmsStatus.failed) {
      debugPrint('failed');
    }
  }
  debugPrint('success');
}

@pragma('vm:entry-point')
Future<void> sendEmergencyMessage() async {
  await prepareMessage();
}

@pragma('vm:entry-point')
Future<void> getCurrentLocation() async {
  address =
      await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
}

@pragma('vm:entry-point')
Future<void> prepareMessage() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    await getCurrentLocation();
    await checkHomecam();
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String>? list = await preferences.getStringList('contactlist');
  if (list != null) {
    recipients = list!;
  }
  if (homecamRegistered) {
    message =
        "${preferences.getString('username')} 님이 24시간 동안 응답이 없습니다.\n현재 예상 위치 : $address";
    if (recipients.isNotEmpty) {
      debugPrint(message);
      debugPrint(recipients.toString());
      await sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
    }
    message = "캠 입장 코드 : $homecamAccessCode\n캠은 워치아웃 앱에서 확인하실 수 있습니다.";
    if (recipients.isNotEmpty) {
      debugPrint(message);
      debugPrint(recipients.toString());
      messageIsSent = true;
      await sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
    }
  } else if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    message =
        "${preferences.getString('username')} 님이 24시간 동안 응답이 없습니다.\n현재 예상 위치 : $address";
    if (recipients.isNotEmpty) {
      debugPrint(message);
      debugPrint(recipients.toString());
      messageIsSent = true;
      await sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
    }
  } else {
    message =
        "${preferences.getString('username')} 님이 24시간 동안 응답이 없습니다.\n현재 예상 위도 : $initLat\n현재 예상 경도 : $initLon";
    if (recipients.isNotEmpty) {
      debugPrint(message);
      debugPrint(recipients.toString());
      messageIsSent = true;
      await sendSMS(message, recipients);
    }
  }
}

@pragma('vm:entry-point')
Future<void> checkHomecam() async {
  await Firebase.initializeApp();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  homecamRegistered = false;
  final homecam = await FirebaseFirestore.instance
      .collection("user")
      .doc(preferences.getString('useruid'))
      .collection("homecam");
  final result = await homecam.get();
  homecamUrl = "";
  result.docs.forEach((value) => {
        homecamUrl = value.get('url'),
      });
  if (homecamUrl.isNotEmpty) {
    homecamRegistered = true;
    homecamAccessCode = getRandomString(8);
    await registerHomecamAccessCode();
  }
}

@pragma('vm:entry-point')
Future<void> registerHomecamAccessCode() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await FirebaseFirestore.instance
      .collection("homecamCodeToUserInfo")
      .doc(homecamAccessCode)
      .set({
    "name": preferences.getString("username"),
    "profileImage": preferences.getString("profileImage"),
    "url": homecamUrl,
    "expiredTime": DateTime.now().add(Duration(minutes: 30)),
  });
}

final _chars = '1234567890';
Random _rnd = Random();

@pragma('vm:entry-point')
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
