import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:sizer/sizer.dart';

class OtherCameraPlayer extends StatefulWidget {
  const OtherCameraPlayer(
      {Key? key, required this.url, required this.expiredTime})
      : super(key: key);

  final Timestamp expiredTime;
  final String url;

  @override
  _OtherCameraPlayerState createState() => _OtherCameraPlayerState();
}

class _OtherCameraPlayerState extends State<OtherCameraPlayer> {
  late VlcPlayerController playerController;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    // 가로 화면 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    playerController = VlcPlayerController.network(widget.url, autoPlay: true);
    Future.delayed(Duration.zero, () {
      checkExpired();
    });
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkExpired();
    });
  }

  void checkExpired() {
    if (DateTime.parse(widget.expiredTime.toDate().toString())
        .isBefore(DateTime.now())) {
      playerController.dispose();
      showDialog(
          context: context,
          builder: (_) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
              12.5.h,
              "홈캠이 만료되었습니다.",
              null)).then((response) => Navigator.of(context).pop());
    }
  }

  @override
  void dispose() {
    // 세로 화면 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
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
    );
  }
}
