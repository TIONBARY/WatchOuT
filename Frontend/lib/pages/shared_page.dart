import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/going_home_map_page.dart';
import 'package:sizer/sizer.dart';

import '../components/dialog/basic_dialog.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<Map<String, dynamic>> _goingHomeUserList = [];
  final _authentication = FirebaseAuth.instance;
  bool isLoading = true;
  String _code = '';

  void addGoingHomeUser() async {
    final response = await FirebaseFirestore.instance
        .collection("codeToUserInfo")
        .doc(_code)
        .get();
    if (response.exists) {
      final userInfo = response.data() as Map<String, dynamic>;
      userInfo["accessCode"] = _code;
      setState(() {
        _goingHomeUserList.add(userInfo);
      });
      FirebaseFirestore.instance
          .collection("goingHomeUserList")
          .doc(_authentication.currentUser?.uid)
          .set({"list": _goingHomeUserList});
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '코드를 잘못 입력하셨습니다.', null);
          });
    }
  }

  void getGoingHomeUserList() async {
    setState(() {
      isLoading = true;
    });

    final response = await FirebaseFirestore.instance
        .collection("goingHomeUserList")
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
          .collection("codeToUserInfo")
          .doc(_list[i]["accessCode"])
          .get();
      if (response.exists) {
        _goingHomeUserList.add(_list[i]);
      }
    }
    FirebaseFirestore.instance
        .collection("goingHomeUserList")
        .doc(_authentication.currentUser?.uid)
        .set({"list": _goingHomeUserList});
    setState(() {
      isLoading = false;
    });
  }

  void updateGoingHomeUserList() async {
    setState(() {
      _goingHomeUserList = [];
    });
    getGoingHomeUserList();
  }

  @override
  void initState() {
    super.initState();
    getGoingHomeUserList();
  }

  bool _isValidCode(String val) {
    if (val.length != 8) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  _goingHomeUserList.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            "귀가 중인 사용자가 없습니다.",
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
                          itemCount: _goingHomeUserList.length,
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
                                          _goingHomeUserList[index]
                                              ["profileImage"]),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    _goingHomeUserList[index]["name"],
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
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => GoingHomeMapPage(
                                                  _goingHomeUserList[index]
                                                      ["homeLat"],
                                                  _goingHomeUserList[index]
                                                      ["homeLon"],
                                                  _goingHomeUserList[index]
                                                      ["accessCode"],
                                                  _goingHomeUserList[index]
                                                      ["profileImage"],
                                                  _goingHomeUserList[index]
                                                      ["name"],
                                                  _goingHomeUserList[index]
                                                      ["phone"])));
                                    },
                                    child: Text(
                                      '위치 확인',
                                      style: TextStyle(fontFamily: 'HanSan'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  Positioned(
                    right: 1.25.w,
                    bottom: 1.25.h,
                    child: FloatingActionButton(
                      heroTag: "shared_page_edit",
                      child: Icon(
                        Icons.edit,
                        size: 20.sp,
                      ),
                      backgroundColor: bColor,
                      onPressed: () {
                        _codeDialog(context);
                      },
                    ),
                  ),
                  Positioned(
                    left: 1.25.w,
                    bottom: 1.25.h,
                    child: FloatingActionButton(
                      heroTag: "shared_page_refresh",
                      child: Icon(Icons.refresh),
                      elevation: 5,
                      hoverElevation: 10,
                      tooltip: "귀가 공유 리스트 갱신",
                      backgroundColor: bColor,
                      onPressed: () {
                        updateGoingHomeUserList();
                      },
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
                          if (_SignupKey.currentState!.validate()) {
                            addGoingHomeUser();
                            Navigator.pop(context);
                          }
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
                          // addGoingHomeUser();
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
