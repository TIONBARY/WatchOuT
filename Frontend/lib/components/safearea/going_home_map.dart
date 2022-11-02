import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoingHomeMap extends StatefulWidget {
  const GoingHomeMap(this.homeLat, this.homeLon, this.accessCode, {Key? key})
      : super(key: key);
  final homeLat;
  final homeLon;
  final accessCode;

  @override
  State<GoingHomeMap> createState() => _GoingHomeMapState();
}

class _GoingHomeMapState extends State<GoingHomeMap> {
  ApiKakao apiKakao = ApiKakao();

  int idx = 0;

  Map<String, dynamic> newValue = {};

  late final Future? myFuture = _getKakaoKey();

  WebViewController? _mapController;
  String kakaoMapKey = "";
  late LocationSettings locationSettings;

  StreamSubscription<Position>? _walkPositionStream;
  StreamSubscription<Position>? _currentPositionStream;

  double initLat = 37.5;
  double initLon = 127.5;

  @override
  void initState() {
    super.initState();
  }

  Future _getKakaoKey() async {
    await dotenv.load();
    kakaoMapKey = dotenv.get('kakaoMapAPIKey');
    final response = await FirebaseFirestore.instance
        .collection("location")
        .doc(widget.accessCode)
        .get();
    initLat = response.data()!["latitude"];
    initLon = response.data()!["longitude"];
    FirebaseFirestore.instance
        .collection("location")
        .doc(widget.accessCode)
        .snapshots()
        .listen((snapshot) {
      initLat = snapshot.get("latitude");
      initLon = snapshot.get("longitude");
      if (_mapController != null) {
        _mapController?.runJavascript('''
        markers[markers.length-1].setMap(null);
        addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
      ''');
      }
    });
    return kakaoMapKey;
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
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 15),
                );
              } else {
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
    addMarker(new kakao.maps.LatLng(${widget.homeLat}, ${widget.homeLon}));
    addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
    var bounds = new kakao.maps.LatLngBounds();    
    bounds.extend(new kakao.maps.LatLng(${widget.homeLat}, ${widget.homeLon}));
    bounds.extend(new kakao.maps.LatLng(${initLat}, ${initLon}));
    map.setBounds(bounds);                      
              ''')
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
    _walkPositionStream?.cancel();
    _currentPositionStream?.cancel();
    super.dispose();
  }
}
