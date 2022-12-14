import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/package_not_found_dialog.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/components/wear/heart_rate_view.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:icon_animated/widgets/icon_animated.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

AuthService authService = AuthService();
const methodChannel = MethodChannel("com.ssafy.homealone/channel");

class SetButton extends StatefulWidget {
  const SetButton({Key? key}) : super(key: key);

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _contactFieldController = TextEditingController();

  List<Map<String, dynamic>> localEmergencyCallList = [];

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

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isAnimationOn = false;
  bool submitted = false;
  bool existUser = false;

  void _showIcon() {
    _animationController.forward();
    setState(() {
      isAnimationOn = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCirc));
    setFirstResponderProvider();
    getEmergencyCallList();
    permitLocationAlways();
  }

  void permitLocationAlways() async {
    if (await Permission.locationAlways.isGranted != true &&
        await Permission.location.isGranted) {
      await showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
              23.h,
              "WatchOuT ????????????????????? '?????? ?????? ??????' ??? '????????? ??????' ?????? ????????? ????????? ??? ????????? '?????? ??????'??? ????????? ?????????."
              "?????? ?????????????????? ?????? ?????? ?????? ????????? ?????? ???????????? ???????????? ????????? ???????????????.",
              null));
      await Permission.locationAlways.request();
      await showDialog(
          context: context,
          builder: (context) => BasicDialog(
              EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
              23.h,
              // '24?????? ????????? ??? ?????? ?????? ?????? ?????????\n????????????????????? ?????? ????????? ????????????,\n?????? ?????? ????????? ???????????? ??? ????????????.\n??? ????????? ?????? ???????????? ?????? ???????????????\n ????????? ?????? ????????? off??? ???????????????.',
              '24?????? ????????? ??? ?????? ?????? ????????? ???????????? ????????? ????????? ???????????? ???????????????. ??? ????????? ?????? ???????????? ???????????? ???????????? ?????? ????????? off??? ???????????????.',
              null));
    }
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
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0.75.h, 0, 0),
      child: Column(
        children: [
          SetPageRadioButton(
            texts: '??????????????? ??????',
            values: Provider.of<SwitchBools>(context, listen: false).useWearOS,
            onchangeds: (value) {
              setState(
                () {
                  Provider.of<SwitchBools>(context, listen: false)
                      .changeWearOS();
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
            texts: '????????? ??????',
            values: Provider.of<SwitchBools>(context, listen: false).useSiren,
            onchangeds: (value) {
              setState(
                () {
                  Provider.of<SwitchBools>(context, listen: false)
                      .changeSiren();
                },
              );
            },
          ),
          SetPageRadioButton(
            texts: '????????? ?????? ??????',
            values: Provider.of<SwitchBools>(context, listen: false).useScreen,
            onchangeds: (value) {
              setState(
                () {
                  Provider.of<SwitchBools>(context, listen: false)
                      .changeScreen();
                },
              );
            },
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 0.5.h),
              margin: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
              decoration: BoxDecoration(
                color: b25Color,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: b25Color.withOpacity(0.125),
                    offset: Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: localEmergencyCallList.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '?????????????????? ??????????????????.',
                          style: TextStyle(
                            fontFamily: 'HanSan',
                          ),
                        ),
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
                        Text(
                          '???????????????',
                          style: TextStyle(
                            fontFamily: 'HanSan',
                          ),
                        ),
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
                                emergencyCallDialog(context);
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
                  openEmergencySetting();
                },
                child: Text(
                  '?????? ??????',
                  style: TextStyle(
                    color: yColor,
                    fontFamily: 'HanSan',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
                      '??????????????? ??????',
                      style: TextStyle(
                        color: bColor,
                        fontSize: 15.sp,
                        fontFamily: 'HanSan',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 7.5.h,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(right: 0.5.w),
                            child: TextField(
                              style: TextStyle(fontFamily: 'HanSan'),
                              autocorrect: false,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              cursorColor: bColor,
                              controller: _nameFieldController,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText: '??????',
                                hintStyle: TextStyle(fontFamily: 'HanSan'),
                                contentPadding: EdgeInsets.fromLTRB(
                                    5.w, 1.25.h, 5.w, 1.25.h),
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
                              style: TextStyle(fontFamily: 'HanSan'),
                              autocorrect: false,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              cursorColor: bColor,
                              controller: _contactFieldController,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText: '????????????',
                                hintStyle: TextStyle(fontFamily: 'HanSan'),
                                contentPadding: EdgeInsets.fromLTRB(
                                    5.w, 1.25.h, 5.w, 1.25.h),
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
                  SizedBox(
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
                          onPressed: () async {
                            Map<String, dynamic>? tmpUser = await UserService()
                                .getUserInfoByNumber(_addContact);
                            if (Provider.of<MyUserInfo>(context, listen: false)
                                    .phone ==
                                _addContact) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return BasicDialog(
                                      EdgeInsets.fromLTRB(
                                          5.w, 2.5.h, 5.w, 0.5.h),
                                      15.h,
                                      '????????????????????? ????????? ????????? \n????????? ??? ????????????.',
                                      null);
                                },
                              );
                              return;
                            }
                            setState(
                              () {
                                localEmergencyCallList.add(
                                    {"name": _addName, "number": _addContact});

                                if (tmpUser == null || tmpUser.isEmpty) {
                                  UserService().registerFirstResponder(
                                      _addName, _addContact);
                                  existUser = false;
                                } else {
                                  UserService().registerExistFirstResponder(
                                      _addName,
                                      _addContact,
                                      tmpUser["googleUID"]);
                                  existUser = true;
                                }
                                getEmergencyCallList();
                                _nameFieldController.clear();
                                _contactFieldController.clear();
                                submitted = true;
                                isAnimationOn = true;
                                Navigator.pop(context);
                                _showIcon();
                                _displayFirstResponderRegister(context);
                              },
                            );
                            // authService.getFirstResponder();
                          },
                          child: Text(
                            '??????',
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
                            setState(() {
                              _nameFieldController.clear();
                              _contactFieldController.clear();
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            '??????',
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
              )),
        );
      },
    );
  }

  Future<void> emergencyCallDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
            height: 30.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: bColor,
                  child: Text(
                    "??????????????? ??????",
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
                  items: localEmergencyCallList
                      .map((e) => MultiSelectItem(e, e["name"]))
                      .toList(),
                  itemsTextStyle: TextStyle(fontFamily: 'WdcsB'),
                  selectedItemsTextStyle: TextStyle(fontFamily: 'WdcsB'),
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
                    scroll: true,
                    scrollBar: HorizontalScrollBar(isAlwaysShown: true),
                  ),
                  selectedColor: yColor,
                  checkColor: bColor,
                  listType: MultiSelectListType.LIST,
                  onConfirm: (values) {
                    _selectedEmergencyCallList = values;
                  },
                  buttonIcon: Icon(
                    Icons.arrow_drop_down,
                    color: bColor,
                  ),
                  buttonText: Text(
                    "???????????????",
                    style: TextStyle(
                      color: bColor,
                      fontFamily: 'HanSan',
                    ),
                  ),
                  dialogHeight: 25.h,
                  title: Text(
                    "????????? ?????????????????? ??????????????????.",
                    style: TextStyle(
                      color: bColor,
                      fontSize: 12.5.sp,
                      fontFamily: 'HanSan',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  confirmText: Text(
                    "??????",
                    style: TextStyle(
                      color: bColor,
                      fontFamily: 'HanSan',
                    ),
                  ),
                  cancelText: Text(
                    "??????",
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
                          '??????',
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
                          "??????",
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

  _displayFirstResponderRegister(BuildContext context) async {
    // Timer(const Duration(seconds: 1), () {
    //   Navigator.of(context).popUntil((route) => route.isFirst);
    // });
    return showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(context);
          });
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.5)),
            child: Container(
              padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
              height: 22.5.h,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: existUser
                      ? [
                          Title(
                            color: bColor,
                            child: Text(
                              'WOT ???????????????.',
                              style: TextStyle(
                                color: bColor,
                                fontSize: 15.sp,
                                fontFamily: 'HanSan',
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: IconAnimated(
                              color: Colors.green,
                              progress: _animation,
                              size: 100,
                              iconType: IconType.check,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text('??? ????????? ????????? ??? ????????????.'),
                          )
                        ]
                      : [
                          Title(
                            color: bColor,
                            child: Text(
                              '??????????????????.',
                              style: TextStyle(
                                color: bColor,
                                fontSize: 15.sp,
                                fontFamily: 'HanSan',
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: IconAnimated(
                              color: Colors.green,
                              progress: _animation,
                              size: 100,
                              iconType: IconType.check,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text('?????? ????????? ????????? ??? ????????????.'),
                          )
                        ]),
            ),
          );
        });
  }

  void openEmergencySetting() {
    methodChannel
        .invokeMethod("openEmergencySetting")
        .catchError(onPlatformError);
  }

  FutureOr<dynamic> onPlatformError(object) {
    debugPrint("?????? ??????");
    // Timer(Duration(seconds: 1), () { showDialog()});
    showDialog(context: context, builder: (context) => PackageNotFoundDialog());
  }
}
