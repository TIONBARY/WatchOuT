import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class RegisterFriendDialog extends StatefulWidget {
  const RegisterFriendDialog(this.function, this.name, this.phone, {Key? key})
      : super(key: key);
  final Function function;
  final String name;
  final String phone;

  @override
  State<RegisterFriendDialog> createState() => _RegisterFriendDialogState();
}

class _RegisterFriendDialogState extends State<RegisterFriendDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0.5.h),
        height: 15.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: Text(
                "${widget.name}(번호 : ${widget.phone}) 님께서 \n친구 요청을 보냈습니다. 수락하시겠습니까?",
                style: TextStyle(fontSize: 15),
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
                      widget.function();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '수락',
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
  }
}
