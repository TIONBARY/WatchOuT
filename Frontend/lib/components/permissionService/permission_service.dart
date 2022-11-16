import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../dialog/basic_dialog.dart';
import '../dialog/permission_rationale_dialog.dart';

class PermissionService {
  Future<void> askPermission(
      BuildContext context, Permission permission, String message) async {
    if (await permission.isGranted) {
      return;
    }
    if (permission == Permission.locationAlways) {
      Future.microtask(() => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BasicDialog(
                  EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
                  23.h,
                  // '24시간 무응답 시 응급 상황 전파 기능은\n백그라운드에서 위치 정보를 수신하고,\n자동 문자 전송이 이루어질 수 있습니다.\n이 기능을 원치 않으시면 설정 페이지에서\n 스크린 사용 감지를 off로 바꿔주세요.',
                  '24시간 무응답 시 비상 연락 기능은 현위치를 포함한 문자가 자동으로 발신됩니다. 이 기능을 원치 않으시면 설정에서 디바이스 사용 감지를 off로 바꿔주세요.',
                  null),
            ),
          ));
    }
    Future.microtask(() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PermissionRationaleDialog(permission, message))));
  }

  bool _permissionLocationAlwaysOnce = false;
  void permissionLocationAlways(BuildContext context) async {
    if (_permissionLocationAlwaysOnce) {
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? permissionOnce = pref.getBool("permissionLocationAlwaysOnce");
    if (permissionOnce != null && permissionOnce!) {
      return;
    }
    _permissionLocationAlwaysOnce = true;

    askPermission(
        context,
        Permission.locationAlways,
        "WatchOuT 백그라운드에서 '응급 상황 전파' 및 '귀갓길 공유' 등의 기능을 사용할 수 있도록 '항상 허용'을 선택해 주세요."
        "앱이 종료되었거나 사용 중이 아닐 때에도 위치 데이터를 수집하여 기능을 가용합니다.");
  }

  bool _permissionLocationsOnce = false;
  void permissionLocation(BuildContext context) async {
    if (_permissionLocationsOnce) {
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? permissionOnce = pref.getBool("permissionLocationsOnce");
    if (permissionOnce != null && permissionOnce!) {
      return;
    }
    _permissionLocationsOnce = true;

    askPermission(context, Permission.location,
        "WatchOuT에서 '안전 지도' 및 '귀갓길 공유' 등의 기능을 사용할 수 있도록 '위치 권한'을 허용해 주세요.앱이 사용 중일때만 데이터를 수집합니다.");
  }

  bool _permissionLSMSOnce = false;
  void permissionSMS(BuildContext context) async {
    if (_permissionLSMSOnce) {
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? permissionOnce = pref.getBool("permissionLSMSOnce");
    if (permissionOnce != null && permissionOnce!) {
      return;
    }
    _permissionLSMSOnce = true;

    askPermission(
        context,
        Permission.sms,
        "WatchOuT에서 '응급 상황 전파', '귀갓길 공유', '귀갓길 공유자에게 문자' 기능에서 '문자 전송 기능'을 사용할 수 있도록 'SMS 권한'을 허용해 주세요."
        "앱이 종료되었거나 사용 중이 아닐 때에도 문자 발송 기능을 가용합니다.");
  }
}
