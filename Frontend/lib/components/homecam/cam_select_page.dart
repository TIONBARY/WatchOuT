import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/homecam/otherCamInfoField.dart';

import '../login/user_service.dart';
import 'cam_info.dart';
import 'camera_player_widget.dart';

class selectPage extends StatelessWidget {
  const selectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () async {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => CameraPlayerWidget()));
              bool flag = await UserService().isHomecamRegistered();
              flag
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraPlayerWidget()))
                  : Navigator.push(context,
                      MaterialPageRoute(builder: (context) => camInfoField()));
            },
            child: Text("내 캠 보기")),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => otherCamInfoField()));
            },
            child: Text("상대 캠 보기")),
      ],
    );
  }
}
