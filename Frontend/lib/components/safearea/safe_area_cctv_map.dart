import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/constants.dart';
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
late WebViewController? _mapController;
String addrName = "";
String kakaoMapKey = "";
String cctvAPIKey = "";
double initLat = 0.0;
double initLon = 0.0;
Timer? timer;
Timer? tempTimer;

class SafeAreaCCTVMap extends StatefulWidget {
  const SafeAreaCCTVMap({Key? key}) : super(key: key);

  @override
  State<SafeAreaCCTVMap> createState() => _SafeAreaCCTVMapState();
}

class _SafeAreaCCTVMapState extends State<SafeAreaCCTVMap> {
  ApiKakao apiKakao = ApiKakao();

  List<Map<String, dynamic>> cctvList = [];
  List<Map<String, dynamic>> sortedcctvList = [];

  int idx = 0;

  String api_url = "";

  String area = "";

  @override
  void initState() {
    super.initState();
  }

  Future _future() async {
    LocationPermission permission = await Geolocator.requestPermission();
    WidgetsFlutterBinding.ensureInitialized();
    Position pos = await Geolocator.getCurrentPosition();
    // await dotenv.load(fileName: ".env");
    await dotenv.load();
    kakaoMapKey = dotenv.get('kakaoMapAPIKey');
    cctvAPIKey = dotenv.get('cctvAPIKey');
    // debugPrint("어싱크 내부");
    initLat = pos.latitude;
    initLon = pos.longitude;
    area = await apiKakao.searchAddr(initLat.toString(), initLon.toString());
    await _search();
    return kakaoMapKey; // 5초 후 '짜잔!' 리턴
  }

  Future<void> _search() async {
    cctvList = [];
    final response = await http.get(Uri.parse(
        'http://openapi.seoul.go.kr:8088/${cctvAPIKey}/json/safeOpenCCTV/1/1000/${area}/'));
    print(response.body);
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
        result['safeOpenCCTV']['row'].forEach((value) => {cctvList.add(value)});
      }
    }
    getSortedCCTVList();
  }

  void getSortedCCTVList() {
    print('sort start');
    cctvList.sort((a, b) => (calculateDistance(initLat, initLon,
            double.parse(a['WGSXPT']), double.parse(a['WGSYPT'])))
        .compareTo(calculateDistance(initLat, initLon,
            double.parse(b['WGSXPT']), double.parse(b['WGSYPT']))));
    sortedcctvList = cctvList.sublist(0, 300);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _updateCurrLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    // await dotenv.load(fileName: ".env");
    await dotenv.load();
    kakaoMapKey = dotenv.get('kakaoMapAPIKey');
    // debugPrint("어싱크 내부");
    initLat = pos.latitude;
    initLon = pos.longitude;
    _mapController!.runJavascript('''
      markers[markers.length-1].setMap(null);
      addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
                future: _future(),
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
                    tempTimer = Timer(Duration(seconds: 1), () {
                      if (timer != null && timer!.isActive) return;
                      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
                        _updateCurrLocation();
                      });
                    });

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
		var zoomControl = new kakao.maps.ZoomControl();
    map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

    var mapTypeControl = new kakao.maps.MapTypeControl();
    map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
              ''',
                          ),
                          Positioned(
                              right: 10.w,
                              bottom: 10.h,
                              child: FloatingActionButton(
                                  child: Icon(Icons.refresh),
                                  elevation: 5,
                                  hoverElevation: 10,
                                  tooltip: "CCTV 리스트 갱신",
                                  backgroundColor: nColor,
                                  onPressed: () {
                                    getSortedCCTVList();
                                  }))
                        ]));
                  }
                })
          ],
        ));
  }

  @override
  void dispose() {
    timer!.cancel();
    tempTimer!.cancel();
    super.dispose();
  }
}
