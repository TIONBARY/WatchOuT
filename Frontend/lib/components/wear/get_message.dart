import 'package:flutter/material.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _watch = WatchConnectivity();
  var _count = 0;
  var heartRate = 0.0;
  var minValue = 80.0;
  var maxValue = 120.0;
  var marginValue = 10.0;
  var isEmergency = false;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  // var _receivedContexts = <Map<String, dynamic>>[];
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  @override
  void initState() {
    super.initState();

    // Change this to the plugin you want to test.
    // e.g. `_watch = WatchConnectivityGarmin();`
    _watch = WatchConnectivity();
    _watch.isPaired.then((value) => _paired = value);
    _watch.isReachable.then((value) => _reachable = value);
    _watch.messageStream.listen((e) => debugPrint(e.toString()));
    _watch.contextStream.listen((e) => updateHeartRate(e.values.last));

    initPlatformState();
  }

  // 워치 접근 가능하고, 심박수 갱신시 실행
  void updateHeartRate(value) {
    debugPrint(value + " 심박수");
    if (_reachable) {
      setState(() {
        heartRate = double.parse(value);
        if (heartRate < (minValue - marginValue) ||
            heartRate >= (maxValue + marginValue)) {
          debugPrint("이상 상황 $heartRate");
          isEmergency = true;
        } else {
          debugPrint("정상범위 심박수 $heartRate");
          isEmergency = false;
        }
      });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    _context = await _watch.applicationContext;
    // debugPrint(_context.toString());
    _receivedContexts = await _watch.receivedApplicationContexts;

    // _watch.contextStream
    //     .listen((e) => setState(() => _log.add('Received context: $e')));

    debugPrint(_receivedContexts.last.values.last);
    if (_reachable) {}
    setState(() {
      // 과거 마지막 기록된 값으로 초기화
      heartRate = double.parse(_receivedContexts.last.values.last);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Supported: $_supported'),
                  Text('Paired: $_paired'),
                  Text('Reachable: $_reachable'),
                  if (_reachable) ...[
                    Text('이상여부: $isEmergency'),
                    Text('현재 심박수: $heartRate'),
                    // Text('Received 메세지: $_receivedContexts'),
                  ],
                  TextButton(
                    onPressed: initPlatformState,
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Send'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text('Message'),
                        onPressed: () {
                          // final message = {'data': 'ㅋㅋㅋ 스마트폰 -> 워치'};
                          final message = {"HEART_RATE": "100"};
                          _watch.sendMessage(message);
                          setState(() => _log.add('Sent message: $message'));
                        },
                      ),
                      ...[
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('Context'),
                          onPressed: () {
                            _count++;
                            final context = {'data': _count};
                            _watch.updateApplicationContext(context);
                            setState(() => _log.add('Sent context: $context'));
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Text('Log'),
                  ..._log.reversed.map((e) => Text(e)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
