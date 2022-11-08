import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/components/singleton/is_check.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/contact_provider.dart';
import '../login/user_service.dart';
import '../wear/heart_rate_view.dart';

final isCheck = IsCheck.instance;

class SetButton extends StatefulWidget {
  const SetButton({Key? key}) : super(key: key);

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _contactFieldController = TextEditingController();
  final List<String> _valueList = ['문자', '전화', '사용안함'];
  String _selectedAlert = '문자';
  List<String> _contactList = [];
  List<String> _nameList = [];
  String _selectedContact = '';
  String _addContact = '';
  String _addName = '';
  bool flag = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> emergencyCallList = [];
  List<Map<String, dynamic>> _selectedEmergencyCallList = [];
  late Future? emergencyCallListFuture = getEmergencyCallList();

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
    setFirstResponderProvider();
    getEmergencyCallList();
  }

  void setFirstResponderProvider() {
    Map<String, String> firstResponder =
        Provider.of<ContactInfo>(context, listen: false).getResponder();
    if (!firstResponder.isEmpty && flag) {
      _nameList = firstResponder.keys.toList();
      _contactList = firstResponder.values.toList();
      flag = false; //최초 한번만 실행되도록 설정
    }
    if (!_nameList.isEmpty) _selectedContact = _nameList[0];
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SwitchBools>(context, listen: false).onCreate();
    Provider.of<HeartRateProvider>(context, listen: false).onCreate();
    return Column(
      children: [
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 1.5.h, 1.w, 0.75.h),
          texts: 'WearOS 사용',
          values: Provider.of<SwitchBools>(context, listen: false).useWearOS,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeWearOS();
            });
          },
        ),
        Provider.of<SwitchBools>(context, listen: true).useWearOS
            ? HeartRateView(
                margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
                provider:
                    Provider.of<HeartRateProvider>(context, listen: false),
              )
            : Container(),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '스크린 사용 감지',
          values: Provider.of<SwitchBools>(context, listen: false).useScreen,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeScreen();
            });
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '위치 정보 전송',
          values: Provider.of<SwitchBools>(context, listen: false).useGPS,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeGPS();
              print('셋버튼다트${isCheck.check}');
              print('셋버튼다트${isCheck.hashCode}');
            });
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '경보음 사용',
          values: Provider.of<SwitchBools>(context, listen: false).useSiren,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeSiren();
            });
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '위험 지대 알림',
          values: Provider.of<SwitchBools>(context, listen: false).useDzone,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeDzone();
            });
          },
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 0.5.h),
            margin: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
            decoration: BoxDecoration(
                color: b25Color, borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: [
                _nameList.isEmpty
                    ? Text('비상연락처를 등록해주세요.')
                    : Flexible(
                        child: MultiSelectDialogField(
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
                            "보호자를 선택해주세요.",
                            style: TextStyle(color: bColor),
                          ),
                          dialogHeight: 25.h,
                          title: Text("삭제할 비상 연락망을 선택해주세요.",
                              style: TextStyle(color: bColor),
                              textAlign: TextAlign.center),
                          confirmText: Text(
                            "확인",
                            style: TextStyle(color: bColor),
                          ),
                          cancelText: Text(
                            "취소",
                            style: TextStyle(color: bColor),
                          ),
                        ),
                      ),
                IconButton(
                  icon: Icon(Icons.delete_sweep_rounded),
                  onPressed: () {
                    setState(() {
                      UserService()
                          .deleteFirstResponderList(_selectedEmergencyCallList);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _displayTextInputDiaLog(context);
                  },
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 1.5.h),
            height: 5.5.h,
            width: double.maxFinite,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                UserDeleteDialog(context);
              },
              child: Text(
                '회원 탈퇴',
                style: TextStyle(
                  color: yColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> UserDeleteDialog(BuildContext context) async {
    final _SignupKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
            height: 16.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: bColor,
                  child: Text(
                    'WatchOuT을 \n정말 탈퇴하시겠습니까?',
                    textAlign: TextAlign.center,
                  ),
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
                          UserService().deleteUser();
                          Navigator.pop(context);
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(
                            color: bColor,
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
                          style: TextStyle(color: bColor),
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

  Future<void> _displayTextInputDiaLog(BuildContext context) async {
    _nameFieldController.clear();
    _contactFieldController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
            height: 27.5.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: bColor,
                  child: Text(
                    '비상 연락망',
                    style: TextStyle(
                      color: bColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Container(
                  height: 12.5.h,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _addName = value;
                          });
                        },
                        controller: _nameFieldController,
                        cursorColor: bColor,
                        decoration: InputDecoration(
                          hintText: '이름 또는 닉네임',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: bColor),
                          ),
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _addContact = value;
                          });
                        },
                        controller: _contactFieldController,
                        keyboardType: TextInputType.phone,
                        cursorColor: bColor,
                        decoration: InputDecoration(
                          hintText: '연락처',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: bColor),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          setState(() {
                            _contactList.add(_addContact);
                            _nameList.add(_addName);
                            UserService()
                                .registerFirstResponder(_addName, _addContact);
                            _nameFieldController.clear();
                            _contactFieldController.clear();
                            // Navigator.pop(context);
                          });
                        },
                        child: Text(
                          '등록',
                          style: TextStyle(
                            color: bColor,
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
                          setState(() {
                            _nameFieldController.clear();
                            _contactFieldController.clear();
                            Navigator.pop(context);
                          });
                        },
                        child: Text(
                          '닫기',
                          style: TextStyle(color: bColor),
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
