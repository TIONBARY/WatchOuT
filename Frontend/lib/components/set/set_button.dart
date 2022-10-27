import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/constants.dart';

class SetButton extends StatefulWidget {
  const SetButton({Key? key}) : super(key: key);

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton> {
  final TextEditingController _textFieldController = TextEditingController();
  final _authentication = FirebaseAuth.instance;
  bool _useWearOS = false;
  bool _useScreen = false;
  bool _useGPS = false;
  bool _useSiren = false;
  bool _useDzone = false;
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
            values: _useWearOS,
            onchangeds: (value) {
              setState(() {
                _useWearOS = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '스크린 사용 감지',
            values: _useScreen,
            onchangeds: (value) {
              setState(() {
                _useScreen = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '위치 정보 전송',
            values: _useGPS,
            onchangeds: (value) {
              setState(() {
                _useGPS = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '경보음 사용',
            values: _useSiren,
            onchangeds: (value) {
              setState(() {
                _useSiren = value;
              });
            }),
        SetPageRadioButton(
            margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
            texts: '위험 지대 알림',
            values: _useDzone,
            onchangeds: (value) {
              setState(() {
                _useDzone = value;
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
        onoff(
          title: '임시버튼',
          isUsed: _useSiren,
        ),
      ],
    );
  }

  Future<void> _displayTextInputDiaLog(BuildContext context) async {
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
                    controller: _textFieldController,
                    decoration: InputDecoration(hintText: '별명을 입력하세요.'),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _addContact = value;
                      });
                    },
                    controller: _textFieldController,
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
                    Navigator.pop(context);
                  });
                },
              )
            ],
          );
        });
  }
}

class onoff extends StatefulWidget {
  onoff({Key? key, required this.title, required this.isUsed})
      : super(key: key);
  final String title;
  bool isUsed;

  @override
  State<onoff> createState() => _onoffState();
}

class _onoffState extends State<onoff> {
  @override
  Widget build(BuildContext context) {
    final String _title = widget.title;
    bool _isUsed = widget.isUsed;

    return SetPageRadioButton(
        margins: EdgeInsets.fromLTRB(2.5.w, 10.h, 2.5.w, 10.h),
        texts: _title,
        values: _isUsed,
        onchangeds: (value) {
          setState(() {
            _isUsed = value;
          });
        });
  }
}
