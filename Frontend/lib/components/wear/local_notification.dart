import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homealone/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

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
  debugPrint("호출 $value");
  if (value == "expand") {
    updateHeartRateRange();
  }
}

// 심박수 범위 변경시
void updateHeartRateRange() async {
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

// 시작시 Wear OS 리스너 등록
void onStartWatch(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    SharedPreferences pref) async {
  final watch = WatchConnectivity();
  // var newGap = "0.0";
  bool? useWearOS = pref.getBool("useWearOS");
  Map<String, String> msg = HashMap<String, String>();
  List<Map<String, dynamic>> contexts = await watch.receivedApplicationContexts;
  if (contexts.isEmpty) {
    return;
  }
  heartRate = double.parse(contexts.last.values.last);
  watch.contextStream.listen(
    (e) async => {
      heartRate = double.parse(e.values.last),
      useWearOS = pref.getBool("useWearOS")!,
      debugPrint("BPM 심박수 $heartRate"),
      msg.clear(),
      msg.addEntries({"HEART_RATE": heartRate.toString()}.entries),
      watch.sendMessage(msg),
      // 임시 이상상황 감지 로직
      if (useWearOS!)
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
