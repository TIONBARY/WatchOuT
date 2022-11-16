import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class OtherCameraPlayer extends StatefulWidget {
  const OtherCameraPlayer({Key? key, required this.url}) : super(key: key);

  final url;

  @override
  _OtherCameraPlayerState createState() => _OtherCameraPlayerState();
}

class _OtherCameraPlayerState extends State<OtherCameraPlayer> {
  late VlcPlayerController playerController;

  @override
  void initState() {
    // 가로 화면 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    playerController = VlcPlayerController.network(widget.url, autoPlay: true);
    super.initState();
  }

  @override
  void dispose() {
    // 세로 화면 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: VlcPlayer(
                      controller: playerController,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    ));
  }
}
