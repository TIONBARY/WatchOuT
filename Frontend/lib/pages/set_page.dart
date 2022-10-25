import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';

class SetPage extends StatefulWidget {
  const SetPage({Key? key}) : super(key: key);

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
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
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: yColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WearOS 사용'),
              Switch(
                  value: _useWearOS,
                  onChanged: (value) {
                    setState(() {
                      _useWearOS = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: yColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('스크린 사용 감지'),
              Switch(
                  value: _useScreen,
                  onChanged: (value) {
                    setState(() {
                      _useScreen = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: yColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('위치 정보 전송'),
              Switch(
                  value: _useGPS,
                  onChanged: (value) {
                    setState(() {
                      _useGPS = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: yColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('경보음 사용'),
              Switch(
                  value: _useSiren,
                  onChanged: (value) {
                    setState(() {
                      _useSiren = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: yColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('위험 지대 알림'),
              Switch(
                  value: _useDzone,
                  onChanged: (value) {
                    setState(() {
                      _useDzone = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: yColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _contactList.isEmpty ? Text('비상연락처를 등록해주세요.') :
                  DropdownButton(
                      value: _selectedContact,
                      items: _nameList.map((value) {
                        return DropdownMenuItem(
                            value: value,
                            child: Text(value)
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedContact = value!;
                        });
                      }
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _displayTextInputDiaLog(context);
                    },
                  ),
                  DropdownButton(
                      value: _selectedAlert,
                      items: _valueList.map((value) {
                        return DropdownMenuItem(
                            value: value,
                            child: Text(value)
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAlert = value!;
                        });
                      }
                  ),
                ],
              ),
            ],
          ),
        ),
        onoff(title: '임시버튼', isUsed: true,)
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
        }
    );
  }
}

class onoff extends StatefulWidget {
  onoff({Key? key, required this.title, required this.isUsed}) : super(key: key);
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

    return Container(
      height: 50,
      width: 300,
      decoration: BoxDecoration(
          color: yColor,
          borderRadius: BorderRadius.circular(20)
      ),
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_title),
          Switch(
              value: _isUsed,
              onChanged: (value) {
                setState(() {
                  _isUsed = value;
                });
              }
          )
        ],
      ),
    );
  }
}
