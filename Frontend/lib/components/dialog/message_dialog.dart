import 'package:flutter/material.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'basic_dialog.dart';

class MessageDialog extends StatefulWidget {
  const MessageDialog(this.phone, {Key? key}) : super(key: key);
  final phone;

  @override
  State<MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  ApiMessage apiMessage = ApiMessage();
  String _message = "";
  TextEditingController textController = TextEditingController();

  void _sendSMS(String message, List<String> recipients) async {
    Map<String, dynamic> _result =
        await apiMessage.sendMessage(recipients, message);
    if (_result["statusCode"] == 200) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, '메세지를 전송했습니다.', null);
          });
      setState(() {
        _message = "";
      });
      textController.text = "";
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BasicDialog(EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
                12.5.h, _result["message"], null);
          });
    }
    print(_result);
  }

  void sendMessage() async {
    String name = Provider.of<MyUserInfo>(context, listen: false).name;
    _sendSMS(
        "${_message}\n* ${name} 님이 WatchOut 앱에서 발송한 문자입니다.", [widget.phone]);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
        height: 25.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: nColor,
              child: Text(
                "전송할 메세지 입력",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(3.5.w, 2.0.h, 3.5.w, 1.25.h),
              child: TextFormField(
                controller: textController,
                autocorrect: false,
                validator: (String? val) {
                  if (val == null || val.length == 0) {
                    return "메세지를 입력해주세요.";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: nColor,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "메세지",
                  helperText: "귀가자에게 보낼 메세지를 작성하세요.",
                  contentPadding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: n25Color),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: nColor),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _message = val;
                  });
                },
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
                      sendMessage();
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