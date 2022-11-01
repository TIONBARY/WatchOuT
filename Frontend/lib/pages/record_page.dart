import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _contactFieldController = TextEditingController();
  final _authentication = FirebaseAuth.instance;

  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            // Positioned(
            //   right: 2.5.w,
            //   bottom: 2.5.h,
            //   child: FloatingActionButton(
            //     child: Icon(
            //       Icons.edit,
            //       size: 20.sp,
            //     ),
            //     backgroundColor: nColor,
            //     onPressed: () {
            //       showDialog(
            //         context: context,
            //         builder: (BuildContext context) {
            //           return _CodeDialog(context);
            //         },
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _CodeDialog(BuildContext context) async {
    _nameFieldController.clear();
    _contactFieldController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
            height: 30.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Title(
                  color: nColor,
                  child: Text(
                    '코드',
                    style: TextStyle(
                      color: nColor,
                      fontSize: 17.5.sp,
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
                            _code = value;
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
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 2.5.h, 0, 0),
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
