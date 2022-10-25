import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
late WebViewController? _mapController;
String addrName = "";
String kakaoMapKey = "";
double initLat = 0.0;
double initLon = 0.0;
Timer? timer;

class SafeAreaMap extends StatefulWidget {
  const SafeAreaMap(this.name, {Key? key}) : super(key: key);

  final name;

  @override
  State<SafeAreaMap> createState() => _SafeAreaMapState();
}

class _SafeAreaMapState extends State<SafeAreaMap> {
  ApiKakao apiKakao = ApiKakao();

  List<Map<String, dynamic>> searchList = [];

  int idx = 0;

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
    // debugPrint("어싱크 내부");
    initLat = pos.latitude;
    initLon = pos.longitude;
    await _search();
    return kakaoMapKey; // 5초 후 '짜잔!' 리턴
  }

  Future<void> _search() async {
    if (widget.name == "안심 택배" || widget.name == "비상벨") return;
    Map<String, dynamic> result = await apiKakao.searchArea(
        widget.name, initLat.toString(), initLon.toString());
    if (result['documents'] != null) {
      searchList = [];
      result['documents'].forEach((value) => {searchList.add(value)});
    }
    print(searchList);
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
                    Timer(Duration(seconds: 1), () {
                      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
                        _updateCurrLocation();
                      });
                    });

                    return Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: KakaoMapView(
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
      var marker = new kakao.maps.Marker({position: position});
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
    
    
    _searchList = ${json.encode({"list": searchList})}["list"];
    var bounds = new kakao.maps.LatLngBounds();
    for(var i = 0 ; i < ${searchList.length} ; i++){
      addMarker(new kakao.maps.LatLng(_searchList[i]['y'], _searchList[i]['x']));
      bounds.extend(new kakao.maps.LatLng(_searchList[i]['y'], _searchList[i]['x']));
      kakao.maps.event.addListener(markers[i], 'click', (function(i) {
        return function(){
          onTapMarker.postMessage(_searchList[i]['place_name']);
        };
      })(i));
    }
    addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
    map.setBounds(bounds);
		var zoomControl = new kakao.maps.ZoomControl();
    map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

    var mapTypeControl = new kakao.maps.MapTypeControl();
    map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
              ''',
                          onTapMarker: (message) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message.message)));
                          }),
                    );
                  }
                })
          ],
        ));
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
}
