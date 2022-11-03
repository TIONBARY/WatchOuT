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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              alignment: Alignment.center, child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  _goingHomeUserList.length == 0
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            "귀가 중인 사용자가 없습니다.",
                            style: TextStyle(fontSize: 15.sp),
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
                                  child: Container(
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
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    _goingHomeUserList[index]["name"],
                                    style: TextStyle(fontSize: 12.5.sp),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0.25.h),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: n50Color,
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
                                                      ["name"])));
                                    },
                                    child: Text('위치 확인'),
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
                      child: Icon(
                        Icons.edit,
                        size: 20.sp,
                      ),
                      backgroundColor: nColor,
                      onPressed: () {
                        _CodeDialog(context);
                      },
                    ),
                  ),
                  Positioned(
                    left: 1.25.w,
                    bottom: 1.25.h,
                    child: FloatingActionButton(
                      child: Icon(Icons.refresh),
                      elevation: 5,
                      hoverElevation: 10,
                      tooltip: "귀가 공유 리스트 갱신",
                      backgroundColor: nColor,
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

  Future<void> _CodeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
            height: 19.5.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SignUpTextField(
                  paddings: EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                  keyboardtypes: TextInputType.text,
                  hinttexts: '코드',
                  helpertexts: '공유 받은 코드를 입력해주세요.',
                  onchangeds: (code) {
                    _code = code;
                  },
                ),
                Container(
                  width: 40.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          addGoingHomeUser();
                          Navigator.pop(context);
                        },
                        child: Text(
                          '등록',
                          style: TextStyle(
                            color: nColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: n25Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          addGoingHomeUser();
                          Navigator.pop(context);
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(color: nColor),
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
