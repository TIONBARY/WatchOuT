import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/homecam/otherCamInfoField.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../login/user_service.dart';
import 'cam_info.dart';
import 'camera_player_widget.dart';

class SelectPage extends StatelessWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WatchOuT',
            style: TextStyle(
              color: yColor,
              fontSize: 20.sp,
              fontFamily: 'HanSan',
            )),
        automaticallyImplyLeading: false,
        backgroundColor: bColor,
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 1.h),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  Provider.of<MyUserInfo>(context, listen: false).profileImage),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedButton(
            height: 7.h,
            width: 30.w,
            blurRadius: 7.5,
            isOutline: true,
            type: PredefinedThemes.light,
            onTap: () async {
              bool flag = await UserService().isHomecamRegistered();
              flag
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraPlayerWidget(),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CamInfoField(),
                      ),
                    );
            },
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '내 캠 보기',
                    style: TextStyle(fontSize: 12.sp, color: bColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(3.sp)),
          AnimatedButton(
            height: 7.h,
            width: 30.w,
            blurRadius: 7.5,
            isOutline: true,
            type: PredefinedThemes.light,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OtherCamInfoField()));
            },
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '친구 캠 보기',
                    style: TextStyle(fontSize: 12.sp, color: bColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
