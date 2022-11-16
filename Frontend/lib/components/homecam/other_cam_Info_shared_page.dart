import 'package:flutter/material.dart';
import 'package:homealone/components/dialog/cam_info_dialog.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import 'others_cam.dart';

class OtherCamInfo extends StatefulWidget {
  const OtherCamInfo({Key? key}) : super(key: key);

  @override
  State<OtherCamInfo> createState() => _OtherCamInfoState();
}

class _OtherCamInfoState extends State<OtherCamInfo> {
  bool isLoading = true;
  String _code = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'WatchOuT',
          style: TextStyle(
            color: yColor,
            fontSize: 20.sp,
            fontFamily: 'HanSan',
          ),
        ),
        backgroundColor: bColor,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 8),
        child: Stack(
          children: [
            _code == ''
                ? Container(
                    alignment: Alignment.center,
                    child: Text(
                      '시청 가능한 상대방이 없습니다.',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'HanSan',
                      ),
                    ),
                  )
                : OthersCam(
                    url: _code,
                  ),
            Positioned(
              left: 1.25.w,
              bottom: 1.25.h,
              child: FloatingActionButton(
                heroTag: "other_cam_info_shared",
                elevation: 5,
                hoverElevation: 10,
                tooltip: "캠 공유 리스트 갱신",
                backgroundColor: bColor,
                onPressed: () {},
                child: Icon(Icons.refresh),
              ),
            ),
            Positioned(
              right: 1.25.w,
              bottom: 1.25.h,
              child: FloatingActionButton(
                heroTag: "other_cam_info_field_edit",
                backgroundColor: bColor,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CamInfoDialog(),
                  );
                },
                child: Icon(
                  Icons.edit,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
