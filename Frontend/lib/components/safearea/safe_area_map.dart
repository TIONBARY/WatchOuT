import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
late WebViewController? _mapController;
String addrName = "";
String kakaoMapKey = "";
double initLat = 0.0;
double initLon = 0.0;

class SafeAreaMap extends StatefulWidget {
  const SafeAreaMap(this.name, {Key? key}) : super(key: key);

  final name;

  @override
  State<SafeAreaMap> createState() => _SafeAreaMapState();
}

class _SafeAreaMapState extends State<SafeAreaMap> {
  @override
  void initState() {
    super.initState();
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
                      ),
                    );
                  }
                })
          ],
        ));
  }
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
  print(initLat.toString() + " " + initLon.toString());
  return kakaoMapKey; // 5초 후 '짜잔!' 리턴
}
