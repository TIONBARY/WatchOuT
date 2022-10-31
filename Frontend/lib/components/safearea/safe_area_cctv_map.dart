import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/components/dialog/call_dialog.dart';
import 'package:homealone/constants.dart';
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:webview_flutter/webview_flutter.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
WebViewController? _mapController;
String addrName = "";
String kakaoMapKey = "";
String cctvAPIKey = "";
String openAPIKey = "";
double initLat = 0.0;
double initLon = 0.0;
late LocationSettings locationSettings;

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

class SafeAreaCCTVMap extends StatefulWidget {
  const SafeAreaCCTVMap({Key? key}) : super(key: key);

  @override
  State<SafeAreaCCTVMap> createState() => _SafeAreaCCTVMapState();
}

class _SafeAreaCCTVMapState extends State<SafeAreaCCTVMap> {
  ApiKakao apiKakao = ApiKakao();

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

  late final Future? myFuture = _future();

  Map<String, dynamic> newValue = {};

  @override
  void initState() {
    super.initState();
  }

  Future _future() async {
    LocationPermission permission = await Geolocator.requestPermission();
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
    _currentPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
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
    Position position = await Geolocator.getCurrentPosition();
    await dotenv.load();
    kakaoMapKey = dotenv.get('kakaoMapAPIKey');
    cctvAPIKey = dotenv.get('cctvAPIKey');
    openAPIKey = dotenv.get('openAPIKey');
    initLat = position.latitude;
    initLon = position.longitude;
    area = await apiKakao.searchAddr(initLat.toString(), initLon.toString());
    await _search();
    // await registerCCTV();
    // await registerSafeOpenBox();
    // await registerEmergencyBell();
    await _searchSafeArea();
    await _searchSafeOpenBox();
    await _searchEmergencyBell();
    return kakaoMapKey; // 5초 후 '짜잔!' 리턴
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
      for (int i = 1001; i < count; i += 1000) {
        final response = await http.get(Uri.parse(
            'http://openapi.seoul.go.kr:8088/${cctvAPIKey}/json/safeOpenCCTV/${i}/${(i + 1000 - 1)}/${area}/'));
        print(response.body);
        final result = await json.decode(response.body);
        if (result['safeOpenCCTV'] == null) return;
        if (result['safeOpenCCTV']['row'] != null) {
          result['safeOpenCCTV']['row']
              .forEach((value) => {cctvList.add(value)});
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
    for (int i = 0; i < 27; i++) {
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

  Future<void> _searchSafeArea() async {
    for (int i = 0; i < 4; i++) {
      Map<String, dynamic> result = await apiKakao.searchArea(
          safeAreaList[i], initLat.toString(), initLon.toString());
      if (result['documents'] != null) {
        safeAreaCoordList[i] = [];
        result['documents']
            .forEach((value) => {safeAreaCoordList[i].add(value)});
      }
    }
  }

  Future<void> _search() async {
    cctvList = [];
    final response =
        await FirebaseFirestore.instance.collection("cctv").doc(area).get();
    final cctvJson = response.data() as Map<String, dynamic>;
    for (int i = 0; i < cctvJson['data'].length; i++) {
      cctvList.add(cctvJson['data'][i]);
    }
    getSortedCCTVList();
  }

  Future<void> _searchSafeOpenBox() async {
    safeOpenBoxList = [];
    final response = await FirebaseFirestore.instance
        .collection("safeOpenBox")
        .doc("data")
        .get();
    final safeOpenBoxJson = response.data() as Map<String, dynamic>;
    for (int i = 0; i < safeOpenBoxJson['data'].length; i++) {
      safeOpenBoxList.add(safeOpenBoxJson['data'][i]);
    }
    getSortedSafeOpenBoxList();
  }

  Future<void> _searchEmergencyBell() async {
    emergencyBellList = [];
    final response = await FirebaseFirestore.instance
        .collection("emergencyBell")
        .doc("서울특별시")
        .get();
    final emergencyBellJson = response.data() as Map<String, dynamic>;
    for (int i = 0; i < emergencyBellJson['data'].length; i++) {
      if (emergencyBellJson['data'][i]['WGSXPT'] != null &&
          emergencyBellJson['data'][i]['WGSYPT'] != null &&
          checkIsDouble(emergencyBellJson['data'][i]['WGSXPT']) &&
          checkIsDouble(emergencyBellJson['data'][i]['WGSYPT']))
        emergencyBellList.add(emergencyBellJson['data'][i]);
    }
    getSortedEmergencyBellList();
  }

  bool checkIsDouble(String number) {
    return double.tryParse(number) != null;
  }

  void getSortedCCTVList() {
    cctvList.sort((a, b) => (calculateDistance(initLat, initLon,
            double.parse(a['WGSXPT']), double.parse(a['WGSYPT'])))
        .compareTo(calculateDistance(initLat, initLon,
            double.parse(b['WGSXPT']), double.parse(b['WGSYPT']))));
    sortedcctvList = cctvList.sublist(0, 200);
  }

  void getSortedSafeOpenBoxList() {
    safeOpenBoxList.sort((a, b) => (calculateDistance(initLat, initLon,
            double.parse(a['WGSXPT']), double.parse(a['WGSYPT'])))
        .compareTo(calculateDistance(initLat, initLon,
            double.parse(b['WGSXPT']), double.parse(b['WGSYPT']))));
    sortedSafeOpenBoxList = safeOpenBoxList;
    safeAreaCoordList[4] = sortedSafeOpenBoxList;
  }

  void getSortedEmergencyBellList() {
    emergencyBellList.sort((a, b) => (calculateDistance(initLat, initLon,
            double.parse(a['WGSXPT']), double.parse(a['WGSYPT'])))
        .compareTo(calculateDistance(initLat, initLon,
            double.parse(b['WGSXPT']), double.parse(b['WGSYPT']))));
    sortedEmergencyBellList = emergencyBellList;
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

  Future<void> _capturePng() async {
    String? path = await NativeScreenshot.takeScreenshot();
    debugPrint(path);
    String fileName = formatDateTime(endTime.toIso8601String()) + ".png";
    String topFolder = await getDirectory();
    moveFile(File(path!), topFolder + "/" + fileName);
  }

  String formatDateTime(String inputTime) {
    String converted = inputTime.trim().split(".").first;
    converted = converted.replaceAll("-", "");
    converted = converted.replaceAll(":", "");
    converted = converted.replaceAll("T", "");
    return converted;
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      debugPrint(e.message);
      final newFile = await sourceFile.copy(newPath);
      Directory tempDir = sourceFile.parent;
      await sourceFile.delete();
      tempDir.deleteSync();
      return newFile;
    }
  }

  Future<String> getDirectory() async {
    Directory? directory =
        await getExternalStorageDirectory(); //from path_provide package
    if (directory != null) {
      debugPrint(directory.toString());
      String path = directory.path + '/' + 'walk';
      new Directory(path).create(recursive: true)
// The created directory is returned as a Future.
          .then((Directory newDirectory) {
        print('Path of New Dir: ' + newDirectory.path);
      });
      return path;
    }
    return "null";
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

  void startWalk(Position position, _mapController) {
    // 연속적인 위치 정보 기록에 사용될 설정

    var lat = position.latitude, // 위도
        lon = position.longitude; // 경도
    positionList = [];

    _mapController.runJavascript('''
                  map.setDraggable(false);
                  map.setZoomable(false);
  ''');
    _currentPositionStream?.cancel();
    _walkPositionStream = _geolocatorPlatform
        .getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (!positionList.contains(position)) {
        if (positionList.length > 0) {
          drawLine(_mapController, position!, positionList.last);
        }
        positionList.add(position!);
      }
      if (position != null) {
        initLat = position!.latitude;
        initLon = position!.longitude;
      }
      _mapController!.runJavascript('''
        markers[markers.length-1].setMap(null);
        addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
      ''');
    });
    if (positionList.length == 0) {
      _mapController.runJavascript('''
                  if ('$position') {
                  // 
                  if (polylineList) {
                      for (i = 0; i < polylineList.length; i++) {
                          // 기존 기록된 경로 삭제
                          polylineList[i].setMap(null);
                      }
                  } 
                  
                  // GeoLocator을 이용해서 얻어온 접속 위치로 이동합니다
                    var lat = parseFloat('$lat'), // 위도
                        lon = parseFloat('$lon'); // 경도
                    var locPosition = new kakao.maps.LatLng(lat, lon);
                    map.setCenter(locPosition);
                      
                  } else { // 위치정보를 사용할 수 없을때 이동할 위치를 설정합니다
                  
                    var locPosition = new kakao.maps.LatLng(37.5013068, 127.0396597); // 멀티캠퍼스 위치
                    map.setCenter(locPosition);
                  }
                  var polylineList = [];
                  var boundList = [];
            ''');
    }
  }

  void drawLine(
      WebViewController _mapController, Position position, Position beforePos) {
    var lat = 0.0, lon = 0.0;
    var beforeLat = 0.0, beforeLon = 0.0;

    lat = position.latitude;
    lon = position.longitude;
    beforeLat = beforePos.latitude;
    beforeLon = beforePos.longitude;
    _mapController.runJavascript('''
                    var lat = parseFloat('$lat'), // 위도
                        lon = parseFloat('$lon'); // 경도
                    var beforeLat = parseFloat('$beforeLat'), // 위도
                        beforeLon = parseFloat('$beforeLon'); // 경도
                    var locPosition = new kakao.maps.LatLng(lat, lon);
                    var beforeLocPosition = new kakao.maps.LatLng(beforeLat, beforeLon);
                    var linePath = [];
                    
                    boundList.push(locPosition); // 바운드 영역 계산용 위치 추가
                    
                    map.setCenter(locPosition);
                    linePath.push(beforeLocPosition);
                    linePath.push(locPosition);
                    
                    // 지도에 표시할 선을 생성합니다
                    var polyline = new kakao.maps.Polyline({
                        path: linePath, // 선을 구성하는 좌표배열 입니다
                        strokeWeight: 5, // 선의 두께 입니다
                        strokeColor: '#FFAE00', // 선의 색깔입니다
                        strokeOpacity: 0.7, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
                        strokeStyle: 'solid' // 선의 스타일입니다
                    });
                    
                    // 지도에 선을 표시합니다 
                    polyline.setMap(map);
                    polylineList.push(polyline);
            ''');
  }

  void stopWalk(WebViewController _mapController) {
    _walkPositionStream?.cancel(); // 위치 기록 종료
    _currentPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        initLat = position!.latitude;
        initLon = position!.longitude;
      }
      _mapController!.runJavascript('''
        markers[markers.length-1].setMap(null);
        addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
      ''');
    });
    _mapController.runJavascript('''
                     map.setDraggable(true);
                     map.setZoomable(true);
                     var bounds = new kakao.maps.LatLngBounds();    
                      for (i = 0; i < boundList.length; i++) {                          
                          // LatLngBounds 객체에 좌표를 추가합니다
                          bounds.extend(boundList[i]);
                      }
                      if ( boundList.length > 1) {
                        map.setBounds(bounds);                      
                      }
                     // bounds[, paddingTop, paddingRight, paddingBottom, paddingLeft]
                     // map.setCenter(new kakao.maps.LatLng(latitude,longitude));
  ''');

    positionList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    // debugPrint(snapshot.data); Container(
                    // child: Text(snapshot.data),

                    return Flexible(
                        flex: 1,
                        fit: FlexFit.loose,
                        child: Stack(children: [
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
      var imageSrc = 'https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/cctvMarker.png?alt=media&token=1ddb3640-c595-4dd8-813c-f1e8ef1df6e0', // 마커이미지의 주소입니다    
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
        for (var i = 4; i < 6; i++) {
          for (var j = 0; j < _safeAreaCoordList[i].length; j++) {
            addSafeAreaMarker(i, new kakao.maps.LatLng(_safeAreaCoordList[i][j]['WGSXPT'], _safeAreaCoordList[i][j]['WGSYPT']));
          }
        }
        
      }
      createSafeAreaMarkers();
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
                                          safeAreaList[json.decode(message
                                              .message)['safe_area_idx']],
                                          json.decode(
                                              message.message)['place_name'],
                                          json.decode(message.message)['phone'],
                                          null);
                                    });
                              }),
                          Positioned(
                              right: 3.w,
                              bottom: 3.h,
                              child: FloatingActionButton(
                                  child: Icon(Icons.refresh),
                                  elevation: 5,
                                  hoverElevation: 10,
                                  tooltip: "CCTV 리스트 갱신",
                                  backgroundColor: nColor,
                                  onPressed: () {
                                    getSortedCCTVList();
                                  })),
                          Positioned(
                              left: 3.w,
                              bottom: 3.h,
                              child: FloatingActionButton(
                                  child: Icon(Icons.emergency_share),
                                  elevation: 5,
                                  hoverElevation: 10,
                                  tooltip: "긴급 신고",
                                  backgroundColor: Colors.red,
                                  onPressed: () {
                                    UrlLauncher.launchUrl(Uri.parse("tel:112"));
                                  })),
                          Positioned(
                              left: 1.w,
                              top: 1.h,
                              child: Wrap(
                                  direction: Axis.vertical,
                                  spacing: 1.h,
                                  children: [
                                    for (var i = 0;
                                        i < safeAreaList.length;
                                        i++)
                                      showSafeArea[i]
                                          ? SizedBox(
                                              width: 23.w,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  removeMarkers(i);
                                                  setState(() {
                                                    showSafeArea[i] = false;
                                                  });
                                                },
                                                child: Text(safeAreaList[i],
                                                    style: TextStyle(
                                                        color: nColor)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: yColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                              ))
                                          : SizedBox(
                                              width: 23.w,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showMarkers(i);
                                                  setState(() {
                                                    showSafeArea[i] = true;
                                                  });
                                                },
                                                child: Text(safeAreaList[i]),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: n50Color,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                              ))
                                  ])),
                          Positioned(
                              left: 0,
                              right: 0,
                              bottom: 3.h,
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (pressWalkBtn == false) {
                                          // 버튼 변경
                                          pressWalkBtn = true;
                                          debugPrint(pressWalkBtn.toString());

                                          // 카카오 맵 이동 기록 시작
                                          Future<Position> future =
                                              _determinePosition();
                                          future
                                              .then((pos) => startWalk(
                                                  pos, _mapController))
                                              .catchError(
                                                  (error) => debugPrint(error));
                                          startTime = DateTime.now();
                                        } else if (pressWalkBtn == true) {
                                          // 버튼 변경
                                          pressWalkBtn = false;
                                          debugPrint(pressWalkBtn.toString());

                                          // 카카오 맵 이동 기록 중단
                                          stopWalk(_mapController!);

                                          // 타이머 정지
                                          // _stopWatchTimer.dispose();
                                          endTime = DateTime.now();
                                          // 백엔드 서버로 전송

                                          sleep(Duration(milliseconds: 500));
                                          // 스크린샷 저장
                                          _capturePng();
                                        }
                                      });
                                    },
                                    child: Text(
                                        pressWalkBtn ? "귀가 종료" : "귀가 시작",
                                        style: TextStyle(
                                            fontSize: 20, color: nColor)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: yColor,
                                      padding: EdgeInsets.all(3.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )))
                        ]));
                  }
                })
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
