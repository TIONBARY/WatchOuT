import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/googleLogin/tab_bar_page.dart';
import 'package:sizer/sizer.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:webview_flutter/webview_flutter.dart';

ApiKakao apiKakao = ApiKakao();

int idx = 0;

Map<String, dynamic> newValue = {};

WebViewController? _mapController;
String kakaoMapKey = "";
late LocationSettings locationSettings;
StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    _currentPositionStream;

double initLat = 37.5;
double initLon = 127.5;

class GoingHomeMap extends StatefulWidget {
  const GoingHomeMap(this.homeLat, this.homeLon, this.accessCode,
      this.profileImage, this.name, this.phone,
      {Key? key})
      : super(key: key);
  final homeLat;
  final homeLon;
  final accessCode;
  final profileImage;
  final name;
  final phone;

  @override
  State<GoingHomeMap> createState() => _GoingHomeMapState();
}

class _GoingHomeMapState extends State<GoingHomeMap> {
  late final Future? myFuture = _getKakaoKey();
  ApiKakao apiKakao = ApiKakao();

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
    _currentPositionStream = FirebaseFirestore.instance
        .collection("location")
        .doc(widget.accessCode)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return BasicDialog(
                  EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                  12.5.h,
                  widget.name + " 님이 귀가를 종료했습니다.",
                  (context) => TabNavBar());
            });
      }
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

  void _sendSMS(String message, List<String> recipients) async {
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  void sendEmergencyMessage() async {
    String address =
        await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
    String message =
        "${widget.name} 님이 현재 위급 상황에 처한 것 같습니다. 확인 부탁드립니다. 현재 예상 위치 : ${address}\n 이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
    List<String> recipients = ["112"];
    _sendSMS(message, recipients);
  }

  void sendMessage() async {
    _sendSMS("", [widget.phone]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(fontSize: 15.sp),
          );
        } else {
          return Container(alignment: Alignment.center, child: SnappingSheet()
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Container(
              //               padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                 children: [
              //                   Flexible(
              //                     flex: 3,
              //                     child: Container(
              //                       child: SizedBox(
              //                         height: 75,
              //                         width: 75,
              //                         child: CircleAvatar(
              //                           backgroundImage:
              //                               NetworkImage(widget.profileImage),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   Column(
              //                     children: [
              //                       Container(
              //                         child: Text(
              //                           widget.name + " 님의 현재 위치",
              //                           style: TextStyle(fontSize: 17.5.sp),
              //                         ),
              //                       ),
              //                       Container(
              //                         width: 50.w,
              //                         child: Row(
              //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
              //                           children: [
              //                             Container(
              //                               alignment: Alignment.center,
              //                               child: ElevatedButton.icon(
              //                                 style: ElevatedButton.styleFrom(
              //                                     primary:
              //                                         nColor //elevated btton background color
              //                                     ),
              //                                 onPressed: () {
              //                                   UrlLauncher.launchUrl(
              //                                       Uri.parse("tel:${widget.phone}"));
              //                                 },
              //                                 icon: Icon(Icons.phone),
              //                                 label: Text(
              //                                   "전화",
              //                                   style: TextStyle(color: Colors.white),
              //                                 ),
              //                               ),
              //                             ),
              //                             Container(
              //                               alignment: Alignment.center,
              //                               child: ElevatedButton.icon(
              //                                 style: ElevatedButton.styleFrom(
              //                                     primary:
              //                                         nColor //elevated btton background color
              //                                     ),
              //                                 onPressed: () {
              //                                   sendMessage();
              //                                 },
              //                                 icon: Icon(Icons.message),
              //                                 label: Text(
              //                                   "문자",
              //                                   style: TextStyle(color: Colors.white),
              //                                 ),
              //                               ),
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   // Flexible(flex: 3, child: Image.asset('assets/heartbeat.gif')),
              //                 ],
              //               ),
              //             ),
              //             Flexible(
              //               flex: 1,
              //               fit: FlexFit.loose,
              //               child: Stack(
              //                 children: [
              //                   KakaoMapView(
              //                       width: MediaQuery.of(context).size.width,
              //                       height: MediaQuery.of(context).size.height,
              //                       // height: size.height * 7 / 10,
              //                       // height: size.height - appBarHeight - 130,
              //                       // height: 1.sh,
              //                       kakaoMapKey: kakaoMapKey,
              //                       lat: initLat,
              //                       lng: initLon,
              //                       // zoomLevel: 1,
              //                       showMapTypeControl: false,
              //                       showZoomControl: false,
              //                       draggableMarker: false,
              //                       // mapType: MapType.TERRAIN,
              //                       mapController: (controller) {
              //                         _mapController = controller;
              //                       },
              //                       customScript: '''
              // var markers = [];
              //
              // function addMarker(position) {
              //   var imageSrc = 'https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/home.png?alt=media&token=184f9f09-4d0c-4ffc-a327-9e1277743a5d', // 마커이미지의 주소입니다
              //       imageSize = new kakao.maps.Size(40, 40); // 마커이미지의 크기입니다
              //       // imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
              //
              //   // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
              //   var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize); // 마커가 표시될 위치입니다
              //
              //   // 마커를 생성합니다
              //   var marker = new kakao.maps.Marker({
              //       position: position,
              //       image: markerImage // 마커이미지 설정
              //   });
              //   marker.setMap(map);
              //   markers.push(marker);
              // }
              // function addCurrMarker(position) {
              //   var imageSrc = 'https://firebasestorage.googleapis.com/v0/b/homealone-6ef54.appspot.com/o/currMarker.png?alt=media&token=140772c4-fac1-4619-a7d2-0f3c03153cbb', // 마커이미지의 주소입니다
              //       imageSize = new kakao.maps.Size(30, 45); // 마커이미지의 크기입니다
              //       // imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
              //
              //   // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
              //   var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize); // 마커가 표시될 위치입니다
              //
              //   // 마커를 생성합니다
              //   var marker = new kakao.maps.Marker({
              //       position: position,
              //       image: markerImage // 마커이미지 설정
              //   });
              //   marker.setMap(map);
              //   markers.push(marker);
              // }
              // addMarker(new kakao.maps.LatLng(${widget.homeLat}, ${widget.homeLon}));
              // addCurrMarker(new kakao.maps.LatLng(${initLat}, ${initLon}));
              // var bounds = new kakao.maps.LatLngBounds();
              // bounds.extend(new kakao.maps.LatLng(${widget.homeLat}, ${widget.homeLon}));
              // bounds.extend(new kakao.maps.LatLng(${initLat}, ${initLon}));
              // map.setBounds(bounds);
              //           '''),
              //                   Positioned(
              //                     left: 0,
              //                     right: 0,
              //                     bottom: 3.h,
              //                     child: FloatingActionButton.large(
              //                       child: Image.asset("assets/siren.png", height: 6.h),
              //                       elevation: 5,
              //                       hoverElevation: 10,
              //                       tooltip: "긴급 신고",
              //                       backgroundColor: yColor,
              //                       onPressed: () {
              //                         sendEmergencyMessage();
              //                       },
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ),
              );
        }
      },
    );
  }

  @override
  void dispose() {
    _currentPositionStream?.cancel();
    super.dispose();
  }
}
