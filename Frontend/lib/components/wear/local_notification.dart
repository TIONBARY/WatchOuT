import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homealone/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

double heartRate = 0.0;
double minValue = 0.0;
double maxValue = 300.0;
bool pressing = false;
String emergencyStatus = "";
String message = "";
List<String> recipients = [];

// this will be used as notification channel id
const notificationChannelId = 'emergency_notification';
late MethodChannel platform;

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
    if (!pressing) {
      pressing = true;
      updateHeartRateRange();
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
  double gapValue = pref.getDouble("gapValue")!;
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
void onStartWatch(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    SharedPreferences pref) async {
  final watch = WatchConnectivity();
  // var newGap = "0.0";
  bool? useWearOS = pref.getBool("useWearOS");
  Map<String, String> msg = HashMap<String, String>();

  var msgStream = watch.messageStream.listen((event) {
    debugPrint("메세지: ${event.values.last}");

    // TODO: 메소드 콜 불가능한 에러 수정
    sendEmergencyMessage();
  });
  // msgStream.onError((error) => {debugPrint(error.toString())});
  // var contexts = await watch.receivedApplicationContexts;
  // heartRate = double.parse(contexts.last.values.last);
  // debugPrint("BPM 심박수1111 $heartRate");

  //처음 1초동안 심박수 체크 안함
  sleep(const Duration(seconds: 1));
  var bpmStream =
      watch.contextStream.listen((e) => {debugPrint("메세지: ${e.values.last}")});
  // bpmStream.onError((error) => {debugPrint(error.toString())});

  bpmStream.onData(
    (data) async {
      heartRate = double.parse(data.values.last);
      await pref.reload();
      useWearOS = pref.getBool("useWearOS")!;
      maxValue = pref.getDouble("maxValue")!;
      minValue = pref.getDouble("minValue")!;
      debugPrint("BPM 심박수 $heartRate");
      msg.clear();
      msg.addEntries({"HEART_RATE": heartRate.toString()}.entries);
      watch.sendMessage(msg);
      // 임시 이상상황 감지 로직
      if (useWearOS!) {
        debugPrint("최대 최소 실시간: $maxValue, $minValue");
        if (heartRate > maxValue || minValue > heartRate) {
          flutterLocalNotificationsPlugin.show(
            notificationId,
            '워치아웃',
            '위기 상황 발생!!! 심박수: ${heartRate.toInt()}',
            // payload: newGap,
            const NotificationDetails(
              android:
                  AndroidNotificationDetails(notificationChannelId, '포그라운드 서비스',
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
          );
          // TODO: 5초간 기다린 뒤에 알림이 해제되지 않았으면 바로 응급알림
          sendEmergencyMessage();
        }
      }
    },
  );
}

void _sendSMS(String message, List<String> recipients) async {
  platform = MethodChannel("com.ssafy.homealone/channel");
  platform.invokeMethod('openEmergencySetting');
  // await platform.invokeMethod(
  //     'sendTextMessage', {'message': message, 'recipients': recipients});
}

Future<void> sendEmergencyMessage() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  maxValue = pref.getDouble("maxValue")!;
  minValue = pref.getDouble("minValue")!;
  if (heartRate > maxValue || minValue > heartRate) {
    emergencyStatus = "이 응급 버튼을 눌렀습니다";
  } else {
    emergencyStatus = "의 심박수가 지정한 범위를 벗어났습니다";
  }

  await prepareMessage(emergencyStatus);
  if (recipients.isNotEmpty) {
    debugPrint(message);
    debugPrint(recipients.toString());
    _sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
  }
}

Future<void> getCurrentLocation() async {
  address =
      await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
}

Future<void> prepareMessage(String emergencyStatus) async {
  await getCurrentLocation();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  message =
      "${preferences.getString('username')}님$emergencyStatus. 긴급 조치가 필요합니다.\n현재 예상 위치 : $address\n이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
  List<String>? list = preferences.getStringList('contactlist');
  if (list != null) {
    recipients = list!;
  }
}
