import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import 'camera_gif.dart';

class OtherCamInfo extends StatefulWidget {
  const OtherCamInfo({Key? key}) : super(key: key);

  @override
  State<OtherCamInfo> createState() => _OtherCamInfoState();
}

class _OtherCamInfoState extends State<OtherCamInfo> {
  bool isLoading = true;
  String _code = '';

  List<Map<String, dynamic>> _homecamUserList = [];
  final _authentication = FirebaseAuth.instance;

  void addHomecamUser() async {
    final response = await FirebaseFirestore.instance
        .collection("homecamCodeToUserInfo")
        .doc(_code)
        .get();
    if (response.exists) {
      final userInfo = response.data() as Map<String, dynamic>;
      userInfo["accessCode"] = _code;
      setState(() {
        _homecamUserList.add(userInfo);
      });
      FirebaseFirestore.instance
          .collection("homecamUserList")
          .doc(_authentication.currentUser?.uid)
          .set({"list": _homecamUserList});
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '코드를 잘못 입력하셨습니다.', null);
          });
    }
  }

  void getHomecamUserList() async {
    setState(() {
      isLoading = true;
    });
    final response = await FirebaseFirestore.instance
        .collection("homecamUserList")
        .doc(_authentication.currentUser?.uid)
        .get();
    if (!response.exists) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final info = response.data() as Map<String, dynamic>;
    final _list = info["list"];
    if (_list == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    for (int i = 0; i < _list.length; i++) {
      final response = await FirebaseFirestore.instance
          .collection("homecamCodeToUserInfo")
          .doc(_list[i]["accessCode"])
          .get();
      if (response.exists) {
        final info = response.data() as Map<String, dynamic>;
        if (DateTime.parse(info["expiredTime"].toDate().toString())
            .isBefore(DateTime.now())) {
          await FirebaseFirestore.instance
              .collection("homecamCodeToUserInfo")
              .doc(_list[i]["accessCode"])
              .delete();
          continue;
        }
        _homecamUserList.add(_list[i]);
      }
    }
    FirebaseFirestore.instance
        .collection("homecamUserList")
        .doc(_authentication.currentUser?.uid)
        .set({"list": _homecamUserList});
    setState(() {
      isLoading = false;
    });
  }

  void updateHomecamUserList() async {
    setState(() {
      _homecamUserList = [];
    });
    getHomecamUserList();
  }

  @override
  void initState() {
    super.initState();
    getHomecamUserList();
  }

  bool _isValidCode(String val) {
    if (val.length != 8) return false;
    return true;
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
      body: isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.only(top: 8),
              child: Stack(
                children: [
                  _homecamUserList.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            "캠을 볼 수 있는 사용자가 없습니다.",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: 'HanSan',
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: _homecamUserList.length,
                          itemBuilder: (context, index) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          _homecamUserList[index]
                                              ["profileImage"]),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    _homecamUserList[index]["name"],
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontFamily: 'HanSan',
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0.25.h),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: bColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) => CameraGif());
                                    },
                                    child: Text(
                                      '캠 확인',
                                      style: TextStyle(
                                        fontFamily: 'HanSan',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                      onPressed: () {
                        updateHomecamUserList();
                      },
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
                        _codeDialog(context);
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

  Future<void> _codeDialog(BuildContext context) async {
    final _SignupKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
            height: 20.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Form(
                  key: _SignupKey,
                  child: SignUpTextField(
                    validations: (String? val) {
                      return _isValidCode(val ?? '') ? null : "올바른 코드를 입력해주세요.";
                    },
                    paddings: EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                    keyboardtypes: TextInputType.number,
                    hinttexts: '코드',
                    helpertexts: '공유 받은 코드를 입력해주세요.',
                    onchangeds: (code) {
                      _code = code;
                    },
                  ),
                ),
                SizedBox(
                  width: 37.5.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          _SignupKey.currentState!.validate()
                              ? {addHomecamUser(), Navigator.pop(context)}
                              : showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BasicDialog(
                                        EdgeInsets.fromLTRB(
                                            5.w, 2.5.h, 5.w, 0.5.h),
                                        12.5.h,
                                        '코드를 확인해주세요.',
                                        null);
                                  },
                                );
                        },
                        child: Text(
                          '등록',
                          style: TextStyle(
                            color: bColor,
                            fontFamily: 'HanSan',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: b25Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: bColor,
                            fontFamily: 'HanSan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
