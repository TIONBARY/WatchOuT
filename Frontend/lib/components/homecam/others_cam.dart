import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class OthersCam extends StatefulWidget {
  const OthersCam({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  State<OthersCam> createState() => _OthersCamState();
}

class _OthersCamState extends State<OthersCam> {
  late VlcPlayerController playerController;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String urlValue = widget.url;
    playerController = VlcPlayerController.network(urlValue, autoPlay: true);
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
                debugPrint("++++++++++++++++++++++++++$urlValue");
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
