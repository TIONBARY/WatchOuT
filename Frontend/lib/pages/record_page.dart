import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final List<String> _items = List.generate(3, (index) => 'Item ${index + 1}');
  final _authentication = FirebaseAuth.instance;

  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          children: [
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Container(
                        child: SizedBox(
                          height: 22.5.h,
                          width: 22.5.w,
                          child: CircleAvatar(
                            backgroundColor: nColor,
                            child: GestureDetector(
                              onTap: () => print('클릭'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text('닉네임'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: n50Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: () {},
                      child: Text('위치 확인'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 1.25.w,
              bottom: 1.25.h,
              child: FloatingActionButton(
                child: Icon(
                  Icons.edit,
                  size: 20.sp,
                ),
                backgroundColor: nColor,
                onPressed: () {
                  _CodeDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _CodeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
            height: 22.5.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignUpTextField(
                  paddings: EdgeInsets.fromLTRB(2.5.w, 1.25.h, 2.5.w, 1.25.h),
                  keyboardtypes: TextInputType.text,
                  hinttexts: '코드',
                  helpertexts: '공유 받은 코드를 입력해주세요.',
                  onchangeds: (code) {
                    _code = code;
                  },
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
                          // setState(() {
                          Navigator.pop(context);
                          // });
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
                          // setState(() {
                          Navigator.pop(context);
                          // });
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
