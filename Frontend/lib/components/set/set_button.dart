import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/constants.dart';
import 'package:provider/provider.dart';
import 'package:homealone/providers/switch_provider.dart';

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
                Provider.of<SwitchBools>(context, listen: false).useWearOS = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '스크린 사용 감지',
            values: Provider.of<SwitchBools>(context, listen: false).useScreen,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useScreen = value;
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
                Provider.of<SwitchBools>(context, listen: false).useSiren = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '위험 지대 알림',
            values: Provider.of<SwitchBools>(context, listen: false).useDzone,
            onchangeds: (value) {
              setState(() {
                Provider.of<SwitchBools>(context, listen: false).useDzone = value;
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
          return AlertDialog(
            title: Text('연락처를 입력해 주세요.'),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _addName = value;
                      });
                    },
                    controller: _nameFieldController,
                    decoration: InputDecoration(hintText: '별명을 입력하세요.'),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _addContact = value;
                      });
                    },
                    controller: _contactFieldController,
                    decoration: InputDecoration(hintText: '연락처를 입력하세요.'),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    _nameFieldController.clear();
                    _contactFieldController.clear();
                    Navigator.pop(context);
                  });
                },
                child: Text('cancel'),
              ),
              ElevatedButton(
                child: Text('confirm'),
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
              )
            ],
          );
        });
  }
}
