import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(const MaterialApp(
    home: CameraPlayerWidget(),
  ));
}

class CameraPlayerWidget extends StatefulWidget {
  const CameraPlayerWidget({Key? key}) : super(key: key);

  @override
  _CameraPlayerWidgetState createState() => _CameraPlayerWidgetState();
}

class _CameraPlayerWidgetState extends State<CameraPlayerWidget> {
  late VlcPlayerController playerController;

  @override
  void initState() {
    super.initState();
    playerController = VlcPlayerController.network(
        "rtsp://watchout:ssafy123@70.12.227.183/stream1",
        autoPlay: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cam',
      home: Scaffold(
        // appBar: AppBar(),
        body: Column(
          children: [
            VlcPlayer(
              controller: playerController,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                playerController.play();
              },
              child: const Text("Play"),
            ),
            ElevatedButton(
              onPressed: () {
                playerController.pause();
              },
              child: const Text("Pause"),
            ),
          ],
        ),
      ),
    );
  }
}
