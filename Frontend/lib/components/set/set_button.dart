import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:provider/provider.dart';

import '../wear/heart_rate_view.dart';

class SetButton extends StatefulWidget {
  const SetButton({Key? key}) : super(key: key);

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _contactFieldController = TextEditingController();
  final _authentication = FirebaseAuth.instance;
  final List<String> _valueList = ['문자', '전화', 'X'];
  String _selectedAlert = '문자';
  List<String> _contactList = ['010123456768', '01043218765'];
  List<String> _nameList = ['엄마', '아빠'];
  String _selectedContact = '엄마';
  String _addContact = '';
  String _addName = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(5.w, 10.h, 2.5.w, 10.h),
            texts: 'WearOS 사용',
            values: Provider.of<SwitchBools>(context, listen: false).useWearOS,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useWearOS =
                    value;
              });
            }),
        Provider.of<SwitchBools>(context, listen: true).useWearOS
            ? HeartRateView(
                margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
                heartRate:
                    Provider.of<HeartRateProvider>(context, listen: false)
                        .heartRate)
            : Container(),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '스크린 사용 감지',
            values: Provider.of<SwitchBools>(context, listen: false).useScreen,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useScreen =
                    value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '위치 정보 전송',
            values: Provider.of<SwitchBools>(context, listen: false).useGPS,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useGPS = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '경보음 사용',
            values: Provider.of<SwitchBools>(context, listen: false).useSiren,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useSiren =
                    value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '위험 지대 알림',
            values: Provider.of<SwitchBools>(context, listen: false).useDzone,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useDzone =
                    value;
              });
            }),
        Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(25.w, 5.h, 25.w, 5.h),
            margin: EdgeInsets.fromLTRB(5.w, 10.h, 5.w, 10.h),
            decoration: BoxDecoration(
                color: n25Color, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _contactList.isEmpty
                    ? Text('비상연락처를 등록해주세요.')
                    : DropdownButton(
                        value: _selectedContact,
                        items: _nameList.map((value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedContact = value!;
                          });
                        }),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _displayTextInputDiaLog(context);
                  },
                ),
                DropdownButton(
                    value: _selectedAlert,
                    items: _valueList.map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAlert = value!;
                      });
                    }),
              ],
            ),
          ),
        ),
      ],
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
            padding: EdgeInsets.fromLTRB(5.w, 10.h, 5.w, 10.h),
            height: 250.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Title(
                  color: nColor,
                  child: Text(
                    '비상 연락망',
                    style: TextStyle(
                      color: nColor,
                      fontSize: 25.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  height: 100.h,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _addName = value;
                          });
                        },
                        controller: _nameFieldController,
                        cursorColor: nColor,
                        decoration: InputDecoration(
                          hintText: '이름 또는 별명',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: nColor),
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
                        cursorColor: nColor,
                        decoration: InputDecoration(
                          hintText: '연락처',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: nColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 17.5.h, 0, 0),
                  width: 150.w,
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
                            print(_contactList.first);
                            _nameFieldController.clear();
                            _contactFieldController.clear();
                            Navigator.pop(context);
                          });
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
                          setState(() {
                            _nameFieldController.clear();
                            _contactFieldController.clear();
                            Navigator.pop(context);
                          });
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
