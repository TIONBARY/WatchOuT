import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random, asin, cos, sqrt;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/components/dialog/access_code_message_choice_list_dialog.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/call_dialog.dart';
import 'package:homealone/constants.dart';
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:webview_flutter/webview_flutter.dart';

import '../permissionService/permission_service.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
WebViewController? _mapController;
String addrName = "";
String kakaoMapKey = "";
String cctvAPIKey = "";
String openAPIKey = "";
double initLat = 37.5013;
double initLon = 127.0396;
late LocationSettings locationSettings;
Timer? timer;
const sendLocationIntervalSec = 30;
const accessCodeLength = 8;

List<Position> positionList = [];
StreamSubscription<Position>? _walkPositionStream;
StreamSubscription<Position>? _currentPositionStream;
bool pressWalkBtn = false;
DateTime startTime = DateTime.now();
DateTime endTime = DateTime.now();

List<String> guName = [
  "강남구",
  "강동구",
  "강북구",
  "강서구",
  "관악구",
  "광진구",
  "구로구",
  "금천구",
  "도봉구",
  "동작구",
  "서대문구",
  "성동구",
  "송파구",
  "영등포구",
  "은평구",
  "중구",
  "노원구",
  "동대문구",
  "마포구",
  "서초구",
  "성북구",
  "양천구",
  "용산구",
  "종로구",
  "중랑구"
];

ApiKakao apiKakao = ApiKakao();
ApiMessage apiMessage = ApiMessage();

List<Map<String, dynamic>> cctvList = [];
List<Map<String, dynamic>> sortedcctvList = [];
List<String> safeAreaList = ["편의점", "파출소", "병원", "약국", "안심 택배", "비상벨"];
List<bool> showSafeArea = [false, false, false, false, false, false];
List<String> safeAreaImages = [
  "https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/convenience-store.png?alt=media&token=ef353640-b18b-4ab4-8079-f76f37251df2",
  "https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/police-station-pin.png?alt=media&token=67f2f7ed-4196-4980-a6f5-4006f8f9dd5a",
  "https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/hospital.png?alt=media&token=372f6988-95fd-49bb-8ce2-fe65875993ce",
  "https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/pharmacy.png?alt=media&token=b04fb0ca-610a-4559-bebe-b23a4903e6f5",
  "https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/box.png?alt=media&token=b683b522-747d-4851-9950-4747347a501d",
  "https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/bell.png?alt=media&token=6946f5fe-9b8c-4d89-950b-44e5a26c86d4"
];
List<List<Map<String, dynamic>>> safeAreaCoordList = [[], [], [], [], [], []];

List<Map<String, dynamic>> safeOpenBoxList = [];
List<Map<String, dynamic>> sortedSafeOpenBoxList = [];
List<Map<String, dynamic>> emergencyBellList = [];
List<Map<String, dynamic>> sortedEmergencyBellList = [];

int idx = 0;

String api_url = "";

String area = "";

ScreenshotController screenshotController = ScreenshotController();

Future? myFuture;

Map<String, dynamic> newValue = {};

String accessCode = "";

String downloadLink =
    "https://play.google.com/store/apps/details?id=com.ssafy.homealone";

const platform = MethodChannel('com.ssafy.homealone/channel');

class SafeAreaCCTVMap extends StatefulWidget {
  const SafeAreaCCTVMap({Key? key}) : super(key: key);

  @override
  State<SafeAreaCCTVMap> createState() => _SafeAreaCCTVMapState();
}

class _SafeAreaCCTVMapState extends State<SafeAreaCCTVMap> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    myFuture ??= _future();
  }

  void permitLocation() async {
    if (await Permission.location.isDenied) {
      PermissionService().permissionLocation(context);
    }
  }

  Future _future() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
        intervalDuration: const Duration(milliseconds: 1000),
      );
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
    if (await Permission.location.isGranted != true) {
      await showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
              23.h,
              "WatchOuT에서 '안전 지도' 및 '귀갓길 공유' 등의 기능을 사용할 수 있도록 '위치 권한'을 허용해 주세요.앱이 사용 중일때만 데이터를 수집합니다.",
              null));
      await Permission.location.request();
    }
    if (await Permission.location.isDenied) {
      await showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              15.h,
              "위치 권한이 없어\n 안전 지도를 사용할 수 없습니다.",
              null));
      return kakaoMapKey;
    }
    final userResponse = await FirebaseFirestore.instance
        .collection("userAccessCode")
        .doc(_auth.currentUser?.uid)
        .get();
    debugPrint(userResponse.exists.toString());
    if (!userResponse.exists) {
      await FirebaseFirestore.instance
          .collection("userAccessCode")
          .doc(_auth.currentUser?.uid)
          .set({"accessCode": ""});
    } else {
      final userAccessCode = userResponse.data() as Map<String, dynamic>;
      if (userAccessCode["accessCode"] != null &&
          userAccessCode["accessCode"].length > 0) {
        pressWalkBtn = true;
        accessCode = userAccessCode["accessCode"];
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    await dotenv.load();
    kakaoMapKey = dotenv.get('kakaoMapAPIKey');
    cctvAPIKey = dotenv.get('cctvAPIKey');
    openAPIKey = dotenv.get('openAPIKey');
    initLat = position.latitude;
    initLon = position.longitude;
    Map<String, dynamic> response =
        await apiKakao.searchAddr(initLat.toString(), initLon.toString());
    bool isInSeoul = response["region_1depth_name"] == "서울특별시";
    area = response["region_2depth_name"];
    if (!isInSeoul) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '안전 지대 정보는 서울에서만 제공됩니다.', null);
          });
      return kakaoMapKey;
    }
    // await registerCCTV();
    // await registerSafeOpenBox();
    // await registerEmergencyBell();
    await _search(context);
    await _searchSafeArea(context);
    await _searchSafeOpenBox(context);
    await _searchEmergencyBell(context);
    return kakaoMapKey; // 5초 후 '짜잔!' 리턴
  }

  Future<void> updateCurrLocation() async {
    Map<String, dynamic> response =
        await apiKakao.searchAddr(initLat.toString(), initLon.toString());
    area = response["region_2depth_name"];
    bool isInSeoul = response["region_1depth_name"] == "서울특별시";
    if (!isInSeoul) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '안전 지대 정보는 서울에서만 제공됩니다.', null);
          });
      return;
    }
    await _search(context);
    await _searchSafeArea(context);
    await _searchEmergencyBell(context);
    _mapController?.runJavascript('''
    for (var i = 0; i < markers.length; i++) {
      markers[i].setMap(null);
    }
    markers = [];
    _cctvList = ${json.encode({"list": sortedcctvList})}["list"];
    for(var i = 0 ; i < ${sortedcctvList.length} ; i++){
      addMarker(new kakao.maps.LatLng(_cctvList[i]['WGSXPT'], _cctvList[i]['WGSYPT']));
    }
    addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
    var _safeAreaCoordList = ${json.encode({
          "list": safeAreaCoordList
        })}["list"];
    createSafeAreaMarkers();
    createAdditionalSafeAreaMarkers();
  ''');
  }

  void startWalk(Position position, _mapController) {
    // 연속적인 위치 정보 기록에 사용될 설정
    _currentPositionStream?.cancel();
    LocationSettings walkLocationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      walkLocationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
          intervalDuration: const Duration(milliseconds: 1000),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "백그라운드에서 위치정보를 받아오고 있습니다.",
            notificationTitle: "WatchOut이 백그라운드에서 실행중입니다.",
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      walkLocationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      walkLocationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }
    _walkPositionStream =
        Geolocator.getPositionStream(locationSettings: walkLocationSettings)
            .listen((Position? position) {
      if (position != null) {
        initLat = position!.latitude;
        initLon = position!.longitude;
      }
      _mapController?.runJavascript('''
        markers[markers.length-1].setMap(null);
        var locPosition = new kakao.maps.LatLng(${initLat}, ${initLon});
        addCurrMarker(locPosition);
        map.panTo(locPosition);
      ''');
    });
    var lat = position.latitude, // 위도
        lon = position.longitude; // 경도
    positionList = [];

    _mapController.runJavascript('''
                  map.setDraggable(false);
                  map.setZoomable(false);
  ''');
    accessCode = getRandomString(accessCodeLength);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AccessCodeMessageChoiceListDialog(
            sendMessageToEmergencyCallList);
      },
    );
    FirebaseFirestore.instance
        .collection("userAccessCode")
        .doc(_auth.currentUser?.uid)
        .update({"accessCode": accessCode});
    FirebaseFirestore.instance
        .collection("user")
        .doc(_auth.currentUser?.uid)
        .get()
        .then((response) {
      Map<String, dynamic> user = response.data() as Map<String, dynamic>;
      FirebaseFirestore.instance
          .collection("codeToUserInfo")
          .doc(accessCode)
          .set({
        "name": user["name"],
        "profileImage": user["profileImage"],
        "phone": user["phone"],
        "homeLat": user["latitude"],
        "homeLon": user["longitude"]
      });
    });
    FirebaseFirestore.instance
        .collection("location")
        .doc(accessCode)
        .set({"latitude": initLat, "longitude": initLon});
    timer = Timer.periodic(Duration(seconds: sendLocationIntervalSec), (timer) {
      debugPrint("Interval Activated");
      debugPrint(initLat!.toString());
      debugPrint(initLon!.toString());
      FirebaseFirestore.instance
          .collection("location")
          .doc(accessCode)
          .set({"latitude": initLat, "longitude": initLon});
    });
  }

  void stopWalk(WebViewController _mapController) {
    _walkPositionStream?.cancel(); // 위치 기록 종료
    timer?.cancel();
    FirebaseFirestore.instance
        .collection("userAccessCode")
        .doc(_auth.currentUser?.uid)
        .update({"accessCode": ""});
    FirebaseFirestore.instance
        .collection("codeToUserInfo")
        .doc(accessCode)
        .delete();
    FirebaseFirestore.instance.collection("location").doc(accessCode).delete();
    _currentPositionStream?.cancel();
    _currentPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        initLat = position!.latitude;
        initLon = position!.longitude;
      }
      _mapController?.runJavascript('''
        markers[markers.length-1].setMap(null);
        addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
      ''');
    });

    positionList = [];
  }

  void _sendSMS(String message, List<String> recipients) async {
    await Permission.sms.request();
    if (await Permission.sms.isDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                15.h, 'SMS 전송 권한이 없어\n 귀가 공유 문자를 전송할 수 없습니다.', null);
          });
      return;
    }
    String _result = await platform.invokeMethod(
        'sendTextMessage', {'message': message, 'recipients': recipients});
    if (_result == "sent") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                17.5.h, '귀갓길 공유 메세지를 전송했습니다.\n지속적인 공유를 위해 앱을 끄지 말아주세요.', null);
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, "메세지 전송에 실패했습니다.", null);
          });
    }
  }

  void sendMessageToEmergencyCallList(
      List<Map<String, dynamic>> _selectedEmergencyCallList) async {
    final response = await FirebaseFirestore.instance
        .collection("user")
        .doc(_auth.currentUser?.uid)
        .get();
    final user = response.data() as Map<String, dynamic>;
    String message =
        "${user["name"]} 님이 귀가를 시작했습니다. 귀가 경로를 확인하시려면 WatchOut 앱에서 다음 입장 코드를 입력하세요.\n입장 코드 : ${accessCode}\n앱 다운로드 링크 : ${downloadLink}";
    List<String> recipients = [];
    for (int i = 0; i < _selectedEmergencyCallList.length; i++) {
      recipients.add(_selectedEmergencyCallList[i]["number"]);
    }
    if (recipients.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '귀갓길 공유 대상을 선택해주세요.', null);
          });
      return;
    }
    _sendSMS(message, recipients);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: myFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //해당 부분은 data를 아직 받아 오지 못했을 때 실행되는 부분
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
                // CircularProgressIndicator();
              }

              //error가 발생하게 될 경우 반환하게 되는 부분
              else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                  style: TextStyle(fontSize: 15),
                );
              }

              // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 부분
              else {
                if (!pressWalkBtn) {
                  _currentPositionStream?.cancel();
                  _currentPositionStream = Geolocator.getPositionStream(
                          locationSettings: locationSettings)
                      .listen((Position? position) {
                    if (position != null) {
                      initLat = position!.latitude;
                      initLon = position!.longitude;
                    }
                    if (_mapController != null) {
                      _mapController?.runJavascript('''
          markers[markers.length-1].setMap(null);
          addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
        ''');
                    }
                  });
                }

                return Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Stack(
                    children: [
                      KakaoMapView(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        // height: size.height * 7 / 10,
                        // height: size.height - appBarHeight - 130,
                        // height: 1.sh,
                        kakaoMapKey: kakaoMapKey,
                        lat: initLat,
                        lng: initLon,
                        // zoomLevel: 1,
                        showMapTypeControl: false,
                        showZoomControl: false,
                        draggableMarker: false,
                        // mapType: MapType.TERRAIN,
                        mapController: (controller) {
                          _mapController = controller;
                        },
                        customScript: '''
    var markers = [];

    function addMarker(position) {
      var imageSrc = 'https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/cctv.png?alt=media&token=42b7c032-e455-456c-993e-a29fdafb9e17', // 마커이미지의 주소입니다    
          imageSize = new kakao.maps.Size(40, 40); // 마커이미지의 크기입니다
          // imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
      
      // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
      var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize); // 마커가 표시될 위치입니다
      
      // 마커를 생성합니다
      var marker = new kakao.maps.Marker({
          position: position, 
          image: markerImage // 마커이미지 설정 
      });
      marker.setMap(map);
      markers.push(marker);
    }
    function addCurrMarker(position) {
      var imageSrc = 'https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/currMarker.png?alt=media&token=140772c4-fac1-4619-a7d2-0f3c03153cbb', // 마커이미지의 주소입니다    
          imageSize = new kakao.maps.Size(30, 45); // 마커이미지의 크기입니다
          // imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
      
      // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
      var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize); // 마커가 표시될 위치입니다
      
      // 마커를 생성합니다
      var marker = new kakao.maps.Marker({
          position: position, 
          image: markerImage // 마커이미지 설정 
      });
      marker.setMap(map);
      markers.push(marker);
    }
    
    
    _cctvList = ${json.encode({"list": sortedcctvList})}["list"];
    for(var i = 0 ; i < ${sortedcctvList.length} ; i++){
      addMarker(new kakao.maps.LatLng(_cctvList[i]['WGSXPT'], _cctvList[i]['WGSYPT']));
      //kakao.maps.event.addListener(markers[i], 'click', (function(i) {
      //  return function(){
      //    onTapMarker.postMessage(JSON.stringify({"place_name": _cctvList[i]['place_name'], "phone": _cctvList[i]['phone']}));
      //  };
      //})(i));
    }
    addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
		// var zoomControl = new kakao.maps.ZoomControl();
    // map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

    // var mapTypeControl = new kakao.maps.MapTypeControl();
    // map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
    
    var markersList = [[], [], [], [], [], []];
    var _safeAreaCoordList = ${json.encode({
                              "list": safeAreaCoordList
                            })}["list"];
    _safeAreaImages = ${json.encode({"list": safeAreaImages})}["list"];
    function addSafeAreaMarker(idx, position) {
        var imageSrc = _safeAreaImages[idx], // 마커이미지의 주소입니다    
            imageSize = new kakao.maps.Size(40, 40); // 마커이미지의 크기입니다
            // imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
        
        // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
        var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize); // 마커가 표시될 위치입니다
        
        // 마커를 생성합니다
        var marker = new kakao.maps.Marker({
            position: position, 
            image: markerImage // 마커이미지 설정 
        });
        markersList[idx].push(marker);
      }
      function createSafeAreaMarkers() {
        for (var i = 0; i < 4; i++) {
          for (var j = 0; j < markersList[i].length; j++) {
            markersList[i][j].setMap(null);
          }
          markersList[i] = [];
        }
        for (var i = 0; i < 4; i++) {
          for (var j = 0; j < _safeAreaCoordList[i].length; j++) {
            addSafeAreaMarker(i, new kakao.maps.LatLng(_safeAreaCoordList[i][j]['y'], _safeAreaCoordList[i][j]['x']));
            kakao.maps.event.addListener(markersList[i][j], 'click', (function(i) {
              var placeName = _safeAreaCoordList[i][j]['place_name'];
              var phone = _safeAreaCoordList[i][j]['phone'];
              return function(){
                onTapMarker.postMessage(JSON.stringify({"safe_area_idx": i, "place_name": placeName, "phone": phone}));
              };
            })(i));
          }
        }        
      }
      function createAdditionalSafeAreaMarkers() {
        for (var i = 4; i < 6; i++) {
          for (var j = 0; j < markersList[i].length; j++) {
            markersList[i][j].setMap(null);
          }
          markersList[i] = [];
        }
        for (var i = 4; i < 6; i++) {
          for (var j = 0; j < _safeAreaCoordList[i].length; j++) {
            addSafeAreaMarker(i, new kakao.maps.LatLng(_safeAreaCoordList[i][j]['WGSXPT'], _safeAreaCoordList[i][j]['WGSYPT']));
          }
        }
      }
      createSafeAreaMarkers();
      createAdditionalSafeAreaMarkers();
      function showMarkers(idx) {
        for (var i = 0; i < markersList[idx].length; i++) {
          markersList[idx][i].setMap(map);
        }
      }
      function removeMarkers(idx) {
        for (var i = 0; i < markersList[idx].length; i++) {
          markersList[idx][i].setMap(null);
        }
      }
              ''',
                        onTapMarker: (message) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CallDialog(
                                  safeAreaList[json.decode(
                                      message.message)['safe_area_idx']],
                                  json.decode(message.message)['place_name'],
                                  json.decode(message.message)['phone'],
                                  null,
                                  null);
                            },
                          );
                        },
                      ),
                      Positioned(
                        child: Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 1.w,
                              children: [
                                for (var i = 0; i < safeAreaList.length; i++)
                                  showSafeArea[i]
                                      ? ElevatedButton(
                                          onPressed: () {
                                            removeMarkers(i);
                                            setState(
                                              () {
                                                showSafeArea[i] = false;
                                              },
                                            );
                                          },
                                          child: Text(
                                            safeAreaList[i],
                                            style: TextStyle(
                                              color: bColor,
                                              fontFamily: 'HanSan',
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.fromLTRB(
                                                2.w, 1.h, 2.w, 1.h),
                                            backgroundColor: yColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            showMarkers(i);
                                            setState(
                                              () {
                                                showSafeArea[i] = true;
                                              },
                                            );
                                          },
                                          child: Text(
                                            safeAreaList[i],
                                            style: TextStyle(
                                              fontFamily: 'HanSan',
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.fromLTRB(
                                                2.w, 1.h, 2.w, 1.h),
                                            backgroundColor: bColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 2.w,
                        bottom: 1.h,
                        child: FloatingActionButton(
                          heroTag: "safe_area_report",
                          elevation: 5,
                          hoverElevation: 10,
                          tooltip: "긴급 신고",
                          backgroundColor: yColor,
                          onPressed: () {
                            UrlLauncher.launchUrl(Uri.parse("tel:112"));
                          },
                          child: Image.asset(
                            "assets/icons/shadowsiren1.png",
                            width: 10.w,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 1.h,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(
                                () {
                                  if (pressWalkBtn == false) {
                                    // 버튼 변경
                                    pressWalkBtn = true;
                                    debugPrint(pressWalkBtn.toString());

                                    // 카카오 맵 이동 기록 시작
                                    Future<Position> future =
                                        _determinePosition();
                                    future
                                        .then((pos) =>
                                            startWalk(pos, _mapController))
                                        .catchError(
                                            (error) => debugPrint(error));
                                    startTime = DateTime.now();
                                  } else if (pressWalkBtn == true) {
                                    // 버튼 변경
                                    pressWalkBtn = false;
                                    debugPrint(pressWalkBtn.toString());

                                    // 카카오 맵 이동 기록 중단
                                    stopWalk(_mapController!);

                                    endTime = DateTime.now();
                                    sleep(Duration(milliseconds: 500));
                                  }
                                },
                              );
                            },
                            child: Text(
                              pressWalkBtn ? "귀가 종료" : "귀가 시작",
                              style: TextStyle(
                                fontSize: 20,
                                color: bColor,
                                fontFamily: 'HanSan',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: yColor,
                              padding: EdgeInsets.all(3.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2.w,
                        bottom: 1.h,
                        child: FloatingActionButton(
                          heroTag: "safe_area_update",
                          elevation: 5,
                          hoverElevation: 10,
                          tooltip: "CCTV 리스트 갱신",
                          backgroundColor: bColor,
                          onPressed: () {
                            updateCurrLocation();
                          },
                          child: Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPositionStream?.cancel();
    super.dispose();
  }
}

Future<void> registerCCTV() async {
  for (int i = 0; i < guName.length; i++) {
    cctvList = [];
    final response = await http.get(Uri.parse(
        'http://openapi.seoul.go.kr:8088/${cctvAPIKey}/json/safeOpenCCTV/1/1000/${guName[i]}/'));
    final result = await json.decode(response.body);
    int count = result['safeOpenCCTV']['list_total_count'];
    if (result['safeOpenCCTV'] == null) return;
    if (result['safeOpenCCTV']['row'] != null) {
      result['safeOpenCCTV']['row'].forEach((value) => {cctvList.add(value)});
    }
    for (int j = 1001; j < count; j += 1000) {
      final response = await http.get(Uri.parse(
          'http://openapi.seoul.go.kr:8088/${cctvAPIKey}/json/safeOpenCCTV/${j}/${(j + 1000 - 1)}/${guName[i]}/'));
      print(response.body);
      final result = await json.decode(response.body);
      if (result['safeOpenCCTV'] == null) return;
      if (result['safeOpenCCTV']['row'] != null) {
        result['safeOpenCCTV']['row'].forEach((value) => {cctvList.add(value)});
      }
    }
    await FirebaseFirestore.instance
        .collection("cctv")
        .doc(guName[i])
        .set({"data": cctvList});
  }
}

Future<void> registerSafeOpenBox() async {
  safeOpenBoxList = [];
  final response = await http.get(Uri.parse(
      'http://openapi.seoul.go.kr:8088/${cctvAPIKey}/json/safeOpenBox/1/300/'));
  final result = await json.decode(response.body);
  if (result['safeOpenBox'] == null) return;
  if (result['safeOpenBox']['row'] != null) {
    result['safeOpenBox']['row']
        .forEach((value) => {safeOpenBoxList.add(value)});
  }
  await FirebaseFirestore.instance
      .collection("safeOpenBox")
      .doc("data")
      .set({"data": safeOpenBoxList});
}

Future<void> registerEmergencyBell() async {
  emergencyBellList = [];
  for (int i = 0; i < 28; i++) {
    final response = await http.get(Uri.parse(
            'http://api.data.go.kr/openapi/tn_pubr_public_safety_emergency_bell_position_api')
        .replace(queryParameters: {
      'pageNo': i.toString(),
      'numOfRows': 1000.toString(),
      'type': 'json',
      'serviceKey': openAPIKey
    }));
    final result = await json.decode(response.body);
    if (result['response']['body']['items'] == null) return;
    if (result['response']['body']['items'] != null) {
      result['response']['body']['items'].forEach((value) => {
            if (value['rdnmadr'].contains("서울특별시") ||
                value['lnmadr'].contains("서울특별시"))
              emergencyBellList.add(
                  {"WGSXPT": value['latitude'], "WGSYPT": value['longitude']})
          });
    }
  }
  await FirebaseFirestore.instance
      .collection("emergencyBell")
      .doc("서울특별시")
      .set({"data": emergencyBellList});
}

void showMarkers(int idx) {
  _mapController!.runJavascript('''
      showMarkers(${idx});
    ''');
}

void removeMarkers(int idx) {
  _mapController!.runJavascript('''
      removeMarkers(${idx});
    ''');
}

Future<void> _searchSafeArea(BuildContext context) async {
  for (int i = 0; i < 4; i++) {
    Map<String, dynamic> result = await apiKakao.searchArea(
        safeAreaList[i], initLat.toString(), initLon.toString());
    if (result['documents'] != null) {
      safeAreaCoordList[i] = [];
      result['documents'].forEach((value) => {safeAreaCoordList[i].add(value)});
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '안전 지대 정보를 불러오지 못했습니다.', null);
          });
      break;
    }
  }
}

Future<void> _search(BuildContext context) async {
  cctvList = [];
  final response =
      await FirebaseFirestore.instance.collection("cctv").doc(area).get();
  if (!response.exists) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h, 'CCTV 정보를 불러오지 못했습니다.', null);
        });
    return;
  }
  final cctvJson = response.data() as Map<String, dynamic>;
  for (int i = 0; i < cctvJson['data'].length; i++) {
    cctvList.add(cctvJson['data'][i]);
  }
  getSortedCCTVList();
}

Future<void> _searchSafeOpenBox(BuildContext context) async {
  safeOpenBoxList = [];
  final response = await FirebaseFirestore.instance
      .collection("safeOpenBox")
      .doc("data")
      .get();
  if (!response.exists) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h, '안심 택배 정보를 불러오지 못했습니다.', null);
        });
    return;
  }
  final safeOpenBoxJson = response.data() as Map<String, dynamic>;
  for (int i = 0; i < safeOpenBoxJson['data'].length; i++) {
    safeOpenBoxList.add(safeOpenBoxJson['data'][i]);
  }
  getSortedSafeOpenBoxList();
}

Future<void> _searchEmergencyBell(BuildContext context) async {
  emergencyBellList = [];
  final String response =
      await rootBundle.loadString('assets/json/emergencyBell.json');
  final data = await json.decode(response);
  print(data[0]['WGSXPT'].runtimeType);
  for (int i = 0; i < data.length; i++) {
    emergencyBellList
        .add({'WGSXPT': data[i]['WGSXPT'], 'WGSYPT': data[i]['WGSYPT']});
  }
  getSortedEmergencyBellList();
}

bool checkIsDouble(String number) {
  return double.tryParse(number) != null;
}

void getSortedCCTVList() {
  cctvList.sort((a, b) => (calculateDistance(initLat, initLon,
          double.parse(a['WGSXPT']), double.parse(a['WGSYPT'])))
      .compareTo(calculateDistance(initLat, initLon, double.parse(b['WGSXPT']),
          double.parse(b['WGSYPT']))));
  sortedcctvList = cctvList.sublist(0, 200);
}

void getSortedSafeOpenBoxList() {
  safeOpenBoxList.sort((a, b) => (calculateDistance(initLat, initLon,
          double.parse(a['WGSXPT']), double.parse(a['WGSYPT'])))
      .compareTo(calculateDistance(initLat, initLon, double.parse(b['WGSXPT']),
          double.parse(b['WGSYPT']))));
  sortedSafeOpenBoxList = safeOpenBoxList;
  safeAreaCoordList[4] = sortedSafeOpenBoxList;
}

void getSortedEmergencyBellList() {
  emergencyBellList.sort((a, b) =>
      (calculateDistance(initLat, initLon, a['WGSXPT'], a['WGSYPT'])).compareTo(
          calculateDistance(initLat, initLon, b['WGSXPT'], b['WGSYPT'])));
  sortedEmergencyBellList = emergencyBellList.sublist(0, 200);
  safeAreaCoordList[5] = sortedEmergencyBellList;
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

String formatDateTime(String inputTime) {
  String converted = inputTime.trim().split(".").first;
  converted = converted.replaceAll("-", "");
  converted = converted.replaceAll(":", "");
  converted = converted.replaceAll("T", "");
  return converted;
}

/// 기능 functions
/// 디바이스의 현재 위치 결정
/// 위치 서비스가 활성화 되어있지 않거나 권한이 없는 경우 `Future` 에러
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('위치 서비스 비활성화');
  }

  // 백그라운드 GPS 권한 요청
  permission = await _geolocatorPlatform.checkPermission();
  // permission = await Permission.locationAlways.status;
  if (permission == LocationPermission.denied) {
    Permission.locationAlways.request();
    permission = await _geolocatorPlatform.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('위치 정보 권한이 없음');
    }
  }

  if (permission == PermissionStatus.granted) {
    return await _geolocatorPlatform.getCurrentPosition();
  } else if (permission == PermissionStatus.permanentlyDenied) {
    return Future.error('백그라운드 위치정보 권한이 영구적으로 거부되어 권한을 요청할 수 없습니다.');
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('위치정보 권한이 영구적으로 거부되어 권한을 요청할 수 없습니다.');
  }

  return await _geolocatorPlatform.getCurrentPosition();
}

final _chars = '1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
