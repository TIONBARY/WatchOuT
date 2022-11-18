import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homealone/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

double heartRate = 0.0;
double minValue = 60.0;
double maxValue = 120.0;
bool pressing = false;
bool interval = false;
String emergencyStatus = "";
String message = "";
List<String> recipients = [];
Set<String> switchKeys = {
  "useWearOS",
  "useScreen",
  "useGPS",
  "useSiren",
  "useDzone",
};

// this will be used as notification channel id
const notificationChannelId = 'emergency_notification';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 119;

bool homecamRegistered = false;
String homecamAccessCode = "";
String homecamUrl = "";

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

Future<void> prepareMessage(String emergencyStatus) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    await getCurrentLocation();
    await checkHomecam();
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String>? list = await preferences.getStringList('contactlist');
  if (list != null) {
    recipients = list;
  }
  if (homecamRegistered) {
    message =
        "${preferences.getString('username')}님$emergencyStatus.\n현재 예상 위치 : $address";
    if (recipients.isNotEmpty) {
      debugPrint(message);
      debugPrint(recipients.toString());
      sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
    }
    message = "홈캠 입장 코드 : $homecamAccessCode\n홈캠은 워치아웃 앱에서 확인하실 수 있습니다.";
    if (recipients.isNotEmpty && !interval) {
      debugPrint(message);
      debugPrint(recipients.toString());
      sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
      interval = true;
      // 30분간 문자 재발송 금지(앱 종료하면 재발송 가능)
      sleep(Duration(minutes: 30));
      interval = false;
    }
  } else if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    message =
        "${preferences.getString('username')}님$emergencyStatus.\n현재 예상 위치 : $address";
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

Future<void> sendEmergencyMessage() async {
  await prepareMessage(emergencyStatus);
  if (recipients.isNotEmpty && !interval) {
    debugPrint(message);
    debugPrint(recipients.toString());
    sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
    interval = true;
    // 30분간 문자 재발송 금지(앱 종료하면 재발송 가능)
    sleep(Duration(minutes: 30));
    interval = false;
  }
}

final _chars = '1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

Future<void> showEmergencyNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    double heartRate,
    double minValue,
    double maxValue) async {
  if (heartRate > maxValue || heartRate < minValue) {
    emergencyStatus = "의 심박수가 지정한 범위를 벗어났습니다";
    flutterLocalNotificationsPlugin.show(
      notificationId,
      '워치아웃',
      '위기 상황 발생!!!\n심박수가 정상 범위에서 벗어났습니다!\n심박수: ${heartRate.toInt()}',
      // payload: newGap,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId, '포그라운드 서비스',
          importance: Importance.max,
          timeoutAfter: 60 * 60 * 1000, // 1시간 뒤에는 자동으로 해제
          onlyAlertOnce: true,
          actions: [
            AndroidNotificationAction("ignore", "무시"),
            AndroidNotificationAction("expand", "심박수 범위 확장"),
            AndroidNotificationAction("open", "앱 열기", showsUserInterface: true),
          ],
          // playSound: ,
          // sound:
        ),
      ),
    );
  } else {
    flutterLocalNotificationsPlugin.show(
      notificationId,
      '워치아웃',
      '위기 상황 발생!!!\n사용자가 버튼을 눌렀습니다!',
      // payload: newGap,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId, '포그라운드 서비스',
          importance: Importance.max,
          timeoutAfter: 60 * 60 * 1000, // 1시간 뒤에는 자동으로 해제
          actions: [
            AndroidNotificationAction("ignore", "무시"),
            AndroidNotificationAction("open", "앱 열기", showsUserInterface: true),
          ],
          // playSound: ,
          // sound:
        ),
      ),
    );
    emergencyStatus = "이 응급 버튼을 눌렀습니다";
  }

  sleep(Duration(seconds: 15));
  List<ActiveNotification> activeNotifications =
      await flutterLocalNotificationsPlugin.getActiveNotifications();
  if (activeNotifications.isNotEmpty) {
    debugPrint("알림 해제 안 됨");
    sendEmergencyMessage();
  }
}

Future<void> initializeNotificationService() async {
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
    // 백그라운드에서 알림 수신시 대응할 함수
    onDidReceiveBackgroundNotificationResponse: onReceiveNotificationResponse,
    // 포그라운드에서 알림 수신시 대응할 함수
    onDidReceiveNotificationResponse: onReceiveNotificationResponse,
  );
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

// 알림에 응답이 발생할 경우 호출되는 함수
void onReceiveNotificationResponse(NotificationResponse response) {
  // print(response.actionId);
  String value = response.actionId!;
  debugPrint("push 알림 응답: $value");
  if (value == "expand") {
    if (!pressing) {
      pressing = true;
      updateHeartRateRange();
      sleep(Duration(seconds: 1));
      pressing = false;
    }
  } else {
    debugPrint("알림 닫기");
  }
}

// 심박수 범위 변경시
void updateHeartRateRange() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.reload();
  maxValue = pref.getDouble("maxValue")!;
  minValue = pref.getDouble("minValue")!;
  double gapValue = 5;
  if (pref.getDouble("gapValue") != null) {
    gapValue = pref.getDouble("gapValue")!;
  }
  double tmpMax = maxValue;
  double tmpMin = minValue;
  if (heartRate > maxValue) {
    tmpMax = maxValue + gapValue;
    pref.setDouble("maxValue", tmpMax > 200 ? 200 : tmpMax);
  } else if (heartRate < minValue) {
    tmpMin = minValue - gapValue;
    pref.setDouble("minValue", tmpMin < 40 ? 40 : tmpMin);
  }
  pref.setDouble("heartRate", heartRate);
  debugPrint("업데이트 결과 $tmpMax, $tmpMin");
}

// 시작시 Wear OS 리스너 등록
// release 모드에서 동작하기 위해 필요
@pragma('vm:entry-point')
void onStartWatch(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  final watch = WatchConnectivity();
  // var newGap = "0.0";
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool? useWearOS = pref.getBool("useWearOS");
  Map<String, String> msg = HashMap<String, String>();

  watch.messageStream.listen((event) {
    print("메세지: ${event.values.last}");
    // debugPrint("메세지: ${event.values.last}");
    sendEmergencyMessage();
  });

  //처음 1초동안 심박수 체크 안함
  sleep(const Duration(seconds: 1));
  var bpmStream = watch.contextStream.listen((e) => {});

  bpmStream.onData(
    (data) async {
      if (!await watch.isReachable) {
        return;
      }
      heartRate = double.parse(data.values.last);
      await pref.reload();

      checkRangeNull(pref);

      useWearOS = pref.getBool("useWearOS")!;
      maxValue = pref.getDouble("maxValue")!;
      minValue = pref.getDouble("minValue")!;
      // debugPrint("BPM 심박수 $heartRate");
      print("BPM 심박수 $heartRate");
      msg.clear();
      msg.addEntries({"HEART_RATE": heartRate.toString()}.entries);
      watch.sendMessage(msg);
      // 임시 이상상황 감지 로직
      if (useWearOS!) {
        debugPrint("최대 최소 실시간: $maxValue, $minValue");
        if (heartRate > maxValue || minValue > heartRate) {
          showEmergencyNotification(
              flutterLocalNotificationsPlugin, heartRate, minValue, maxValue);
        }
      }
    },
  );
}

// 초기화
void checkRangeNull(SharedPreferences pref) {
  // bool 값들 초기화
  if (pref.getBool("useWearOS") == null) {
    for (var key in switchKeys) {
      if (pref.getBool(key) == null) {
        pref.setBool(key, true);
      }
    }
  }

  Set<String> rangeKeys = {
    "heartRate",
    "minValue",
    "maxValue",
    "gapValue",
  };

  // bool 값들 초기화
  if (pref.getDouble("maxValue") == null ||
      pref.getDouble("minValue") == null ||
      pref.getDouble("gapValue") == null) {
    for (var key in rangeKeys) {
      if (pref.getDouble(key) == null) {
        switch (key) {
          case "maxValue":
            pref.setDouble(key, 120);
            break;
          case "minValue":
            pref.setDouble(key, 60);
            break;
          case "gapValue":
            pref.setDouble(key, 5);
            break;
          case "heartRate":
            pref.setDouble(key, 0);
            break;
        }
      }
    }
  }
}
