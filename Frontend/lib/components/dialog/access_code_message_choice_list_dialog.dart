import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizer/sizer.dart';

class AccessCodeMessageChoiceListDialog extends StatefulWidget {
  const AccessCodeMessageChoiceListDialog(this.sendMessageToEmergencyCallList,
      {Key? key})
      : super(key: key);
  final Function sendMessageToEmergencyCallList;

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
  String downloadLink =
      "https://play.google.com/store/apps/details?id=com.ssafy.homealone";
  ApiMessage apiMessage = ApiMessage();

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
              color: bColor,
              child: Text(
                "귀갓길 공유",
                style: TextStyle(
                  color: bColor,
                  fontSize: 15.sp,
                  fontFamily: 'HanSan',
                ),
              ),
            ),
            MultiSelectDialogField(
              decoration: BoxDecoration(
                border: Border.all(color: b25Color),
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
                chipColor: bColor,
                textStyle: TextStyle(color: Colors.white),
              ),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                _selectedEmergencyCallList = values;
              },
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: bColor,
              ),
              buttonText: Text(
                "비상연락망",
                style: TextStyle(
                  color: bColor,
                  fontFamily: 'HanSan',
                ),
              ),
              dialogHeight: 25.h,
              title: Text('귀갓길을 공유할 \n보호자를 선택해주세요.',
                  style: TextStyle(
                    color: bColor,
                    fontSize: 12.5.sp,
                    fontFamily: 'HanSan',
                  ),
                  textAlign: TextAlign.center),
              confirmText: Text(
                "확인",
                style: TextStyle(
                  color: bColor,
                  fontFamily: 'HanSan',
                ),
              ),
              cancelText: Text(
                "취소",
                style: TextStyle(
                  color: bColor,
                  fontFamily: 'HanSan',
                ),
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
                      widget.sendMessageToEmergencyCallList(
                          _selectedEmergencyCallList);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '전송',
                      style: TextStyle(
                        color: bColor,
                        fontFamily: 'HanSan',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: b25Color,
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
  }
}
