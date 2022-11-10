import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/contact_provider.dart';
import '../login/user_service.dart';
import '../wear/heart_rate_view.dart';

AuthService authService = AuthService();

class SetButton extends StatefulWidget {
  const SetButton({Key? key}) : super(key: key);

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _contactFieldController = TextEditingController();

  List<Map<String, dynamic>> localEmergencyCallList = [];
  // List<String> _contactList = [];
  // List<String> _nameList = [];

  String _addContact = '';
  String _addName = '';
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
    List<String> _nameList;
    List<String> _contactList;
    if (!firstResponder.isEmpty) {
      _nameList = firstResponder.keys.toList();
      _contactList = firstResponder.values.toList();
      for (int i = 0; i < _nameList.length; i++) {
        localEmergencyCallList
            .add({"name": _nameList[i], "number": _contactList[i]});
      }
    }
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
            setState(
              () {
                Provider.of<SwitchBools>(context, listen: false).changeWearOS();
              },
            );
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
            setState(
              () {
                Provider.of<SwitchBools>(context, listen: false).changeScreen();
              },
            );
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '위치 정보 전송',
          values: Provider.of<SwitchBools>(context, listen: false).useGPS,
          onchangeds: (value) {
            setState(
              () {
                Provider.of<SwitchBools>(context, listen: false).changeGPS();
              },
            );
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '경보음 사용',
          values: Provider.of<SwitchBools>(context, listen: false).useSiren,
          onchangeds: (value) {
            setState(
              () {
                Provider.of<SwitchBools>(context, listen: false).changeSiren();
              },
            );
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '위험 지대 알림',
          values: Provider.of<SwitchBools>(context, listen: false).useDzone,
          onchangeds: (value) {
            setState(
              () {
                Provider.of<SwitchBools>(context, listen: false).changeDzone();
              },
            );
          },
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 0.5.h),
            margin: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
            decoration: BoxDecoration(
                color: b25Color, borderRadius: BorderRadius.circular(25)),
            child: localEmergencyCallList.isEmpty
                ? Row(
                    children: [
                      Text('비상연락망을 등록해주세요.'),
                      IconButton(
                        onPressed: () {
                          _displayTextInputDiaLog(context);
                        },
                        icon: Icon(Icons.add_circle, size: 20.sp),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('비상연락망'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _displayTextInputDiaLog(context);
                            },
                            icon: Icon(Icons.add_circle, size: 20.sp),
                          ),
                          IconButton(
                            onPressed: () {
                              EmergencyCallDialog(context);
                            },
                            icon: Icon(Icons.delete, size: 20.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        Flexible(
          child: Row(
            children: [],
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
    // final _SignupKey = GlobalKey<FormState>();
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
            height: 22.5.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: bColor,
                  child: Text(
                    '비상연락망 추가',
                    style: TextStyle(
                      color: bColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Container(
                  height: 7.5.h,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(right: 0.5.w),
                          child: TextField(
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            cursorColor: bColor,
                            controller: _nameFieldController,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: '이름',
                              contentPadding:
                                  EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(color: b25Color),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(color: bColor),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _addName = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(left: 0.5.w),
                          child: TextField(
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            cursorColor: bColor,
                            controller: _contactFieldController,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: '전화번호',
                              contentPadding:
                                  EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(color: b25Color),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(color: bColor),
                              ),
                            ),
                            onChanged: (value) {
                              setState(
                                () {
                                  _addContact = value;
                                },
                              );
                            },
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
                          setState(
                            () {
                              localEmergencyCallList.add(
                                  {"name": _addName, "number": _addContact});
                              UserService().registerFirstResponder(
                                  _addName, _addContact);
                              getEmergencyCallList();
                              _nameFieldController.clear();
                              _contactFieldController.clear();
                              Navigator.pop(context);
                            },
                          );
                          authService.getFirstResponder();
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

  Future<void> EmergencyCallDialog(BuildContext context) async {
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
                    "비상연락망 삭제",
                    style: TextStyle(
                      color: bColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                MultiSelectDialogField(
                  decoration: BoxDecoration(
                    border: Border.all(color: b25Color),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  items: localEmergencyCallList
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
                    chipColor: yColor,
                    textStyle: TextStyle(color: bColor),
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
                    style: TextStyle(color: bColor),
                  ),
                  dialogHeight: 25.h,
                  title: Text(
                    "삭제할 비상연락망을 선택해주세요.",
                    style: TextStyle(
                      color: bColor,
                      fontSize: 12.5.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  confirmText: Text(
                    "확인",
                    style: TextStyle(color: bColor),
                  ),
                  cancelText: Text(
                    "취소",
                    style: TextStyle(color: bColor),
                  ),
                ),
                Container(
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
                          setState(
                            () {
                              for (int i = 0;
                                  i < _selectedEmergencyCallList.length;
                                  i++) {
                                localEmergencyCallList
                                    .remove(_selectedEmergencyCallList[i]);
                                Provider.of<ContactInfo>(context, listen: false)
                                    .getResponder()
                                    .remove(
                                        _selectedEmergencyCallList[i]['name']);
                              }
                              UserService().deleteFirstResponderList(
                                  _selectedEmergencyCallList);
                              Navigator.of(context).pop();
                            },
                          );
                          authService.getFirstResponder();
                        },
                        child: Text(
                          '삭제',
                          style: TextStyle(color: bColor),
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
