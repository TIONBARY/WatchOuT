import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:homealone/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizer/sizer.dart';

class AccessCodeMessageChoiceListDialog extends StatefulWidget {
  const AccessCodeMessageChoiceListDialog(this.accessCode, {Key? key})
      : super(key: key);

  final accessCode;

  @override
  State<AccessCodeMessageChoiceListDialog> createState() =>
      _AccessCodeMessageChoiceListDialogState();
}

class _AccessCodeMessageChoiceListDialogState
    extends State<AccessCodeMessageChoiceListDialog> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> emergencyCallList = [];
  List<Map<String, dynamic>> _selectedEmergencyCallList = [];
  late Future? emergencyCallListFuture = getEmergencyCallList();
  String downloadLink = "Download Link";

  Future<List<Map<String, dynamic>>> getEmergencyCallList() async {
    final firstResponder = await FirebaseFirestore.instance
        .collection("user")
        .doc(_auth.currentUser?.uid)
        .collection("firstResponder");
    final result = await firstResponder.get();
    setState(() {
      emergencyCallList = [];
    });
    result.docs.forEach((value) => {
          emergencyCallList
              .add({"name": value.id, "number": value.get("number")})
        });
    return emergencyCallList;
  }

  void _sendSMS(String message, List<String> recipients) async {
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  void sendMessageToEmergencyCallList() async {
    // if (_selectedEmergencyCallList.length > 2) {
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
    //             12.5.h, '귀갓길 공유는 최대 2명까지만 가능합니다.', null);
    //       });
    //   return;
    // }
    final response = await FirebaseFirestore.instance
        .collection("user")
        .doc(_auth.currentUser?.uid)
        .get();
    final user = response.data() as Map<String, dynamic>;
    String message =
        "${user["name"]} 님이 귀가를 시작했습니다. 귀가 경로를 확인하시려면 WatchOut 앱에서 다음 입장 코드를 입력하세요.\n입장 코드 : ${widget.accessCode}\n앱 다운로드 링크 : ${downloadLink}";
    List<String> recipients = [];
    for (int i = 0; i < _selectedEmergencyCallList.length; i++) {
      recipients.add(_selectedEmergencyCallList[i]["number"]);
    }
    _sendSMS(message, recipients);
  }

  @override
  void initState() {
    super.initState();
    emergencyCallListFuture = getEmergencyCallList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
        height: 27.5.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: nColor,
              child: Text(
                "귀갓길 공유",
                style: TextStyle(
                  color: nColor,
                  fontSize: 15.sp,
                ),
              ),
            ),
            Container(
              child: MultiSelectDialogField(
                decoration: BoxDecoration(
                  border: Border.all(color: n25Color),
                  borderRadius: BorderRadius.circular(5),
                ),
                items: emergencyCallList
                    .map((e) => MultiSelectItem(e, e["name"]))
                    .toList(),
                chipDisplay: MultiSelectChipDisplay(
                  items: _selectedEmergencyCallList
                      .map((e) => MultiSelectItem(e, e["name"]))
                      .toList(),
                  onTap: (value) {
                    setState(() {
                      _selectedEmergencyCallList.remove(value);
                    });
                  },
                  chipColor: nColor,
                  textStyle: TextStyle(color: Colors.white),
                ),
                listType: MultiSelectListType.LIST,
                onConfirm: (values) {
                  _selectedEmergencyCallList = values;
                },
                buttonIcon: Icon(
                  Icons.arrow_drop_down,
                  color: nColor,
                ),
                buttonText: Text(
                  "귀갓길을 공유할 보호자를 선택해주세요.",
                  style: TextStyle(color: nColor),
                ),
                dialogHeight: 25.h,
                title: Text("최대 2명까지 가능합니다.",
                    style: TextStyle(color: nColor),
                    textAlign: TextAlign.center),
                confirmText: Text(
                  "확인",
                  style: TextStyle(color: nColor),
                ),
                cancelText: Text(
                  "취소",
                  style: TextStyle(color: nColor),
                ),
              ),
            ),
            Container(
              width: 35.w,
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
                      sendMessageToEmergencyCallList();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '전송',
                      style: TextStyle(color: nColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: n25Color,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "취소",
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
  }
}
