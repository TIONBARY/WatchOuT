import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/login/sign_up_text_field.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ModifyUserInfo extends StatefulWidget {
  const ModifyUserInfo({
    Key? key,
  }) : super(key: key);

  @override
  State<ModifyUserInfo> createState() => _ModifyUserInfoState();
}

class _ModifyUserInfoState extends State<ModifyUserInfo> {
  final TextEditingController _textController = new TextEditingController();
  Widget _changedTextWidget = Container();

  final _SignupKey = GlobalKey<FormState>();

  String postCode = '';
  String region = '';
  String latitude = '-';
  String longitude = '-';

  String? _nickname = '';
  String? _phone = '';

  late TextEditingController _phoneController;

  File? profileImage;
  final picker = ImagePicker();

  Future<void> chooseImage() async {
    var choosedimage = await picker.pickImage(source: ImageSource.gallery);
    //set source: ImageSource.camera to get image from camera
    setState(() {
      profileImage = File(choosedimage!.path);
    });
  }

  final FirebaseAuth _authentication = FirebaseAuth.instance;
  User? loggedUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Map userData;

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print("sign_up.dart에서 user 정보를 잘 받아왔습니다.");
      }
    } catch (e) {
      print("sign_up.dart에서 유저 정보를 받아오지 못했습니다.");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _phoneController = TextEditingController(
        text: Provider.of<MyUserInfo>(context, listen: false).phone);
  }

  Future<void> _update() async {
    _SignupKey.currentState!.save();
    db.collection("user").doc("${loggedUser!.uid}").update({
      "nickname": _nickname,
      "name": Provider.of<MyUserInfo>(context, listen: false).name,
      "gender": Provider.of<MyUserInfo>(context, listen: false).gender,
      "birth": Provider.of<MyUserInfo>(context, listen: false).birth,
      "phone": _phone,
      "region": '(${this.postCode}) ${this.region}',
      "latitude": '${this.latitude}',
      "longitude": '${this.longitude}',
      "profileImage": '',
      "activated": true,
    });
  }

  bool _isValidPhone(String val) {
    return RegExp(r'^010\d{7,8}$').hasMatch(val);
  }

  bool _isValidBirth(String val) {
    if (val.length != 6) return false;
    return RegExp(r'(?:[0]9)?[0-9]{6}$').hasMatch(val);
  }

  bool _isValidname(String val) {
    if (val.length > 10 && val.length < 2) // 길이 검사
      return false;
    if (val.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) //특수 기호 있으면 false
      return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String address = Provider.of<MyUserInfo>(context, listen: false).region;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _SignupKey,
        child: ListView(
          children: [
            Container(
              height: 20.h,
              color: b75Color,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 4.h, 0, 0),
                child: Image(
                  image: AssetImage('assets/WatchOuT_Logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(15.w, 2.5.h, 1.25.w, 1.25.h),
                  child: Text(
                    '이름 : ',
                    style: TextStyle(fontSize: 12.5.sp),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(1.25.w, 2.5.h, 1.25.w, 1.25.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 1.25.w, 1.25.h),
                    width: 63.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.75.sp,
                          color: b25Color,
                        )),
                    child: Text(
                      Provider.of<MyUserInfo>(context, listen: false).name,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12.5.sp),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 1.25.w, 1.25.h),
                  child: Text(
                    '생년월일 : ',
                    style: TextStyle(fontSize: 12.5.sp),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(1.25.w, 1.25.h, 1.25.w, 1.25.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 1.25.w, 1.25.h),
                    width: 63.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.75.sp,
                          color: b25Color,
                        )),
                    child: Text(
                      Provider.of<MyUserInfo>(context, listen: false).birth,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12.5.sp),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(15.w, 1.25.h, 1.25.w, 1.25.h),
                  child: Text(
                    '성별 : ',
                    style: TextStyle(fontSize: 12.5.sp),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(1.25.w, 1.25.h, 1.25.w, 1.25.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 1.25.w, 1.25.h),
                    width: 63.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.75.sp,
                          color: b25Color,
                        )),
                    child: Text(
                      Provider.of<MyUserInfo>(context, listen: false).gender ==
                              'M'
                          ? '남자'
                          : '여자',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12.5.sp),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 7.5.w, 1.25.h),
              child: Divider(
                color: b50Color,
                thickness: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(5.w, 0, 0, 0),
                  height: 75,
                  width: 75,
                  child: Center(
                    child: profileImage == null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                Provider.of<MyUserInfo>(context, listen: false)
                                    .profileImage),
                            radius: 200,
                          )
                        : new CircleAvatar(
                            backgroundImage: new FileImage(
                              File(profileImage!.path),
                            ),
                            radius: 200,
                          ),
                  ),
                  decoration:
                      BoxDecoration(color: b25Color, shape: BoxShape.circle),
                ),
                Container(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      chooseImage(); // call choose image function
                    },
                    icon: Icon(Icons.image),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: bColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                    label: Text(
                      "프로필 이미지 (선택)",
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(7.5.w, 2.5.h, 7.5.w, 1.25.h),
              child: TextFormField(
                autocorrect: false,
                controller: _phoneController,
                validator: (String? val) {
                  return _isValidPhone(val ?? '')
                      ? null
                      : "올바른 전화번호 형식으로 입력해주세요.";
                },
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                cursorColor: bColor,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: '전화번호',
                  helperText: '숫자만 입력해주세요.',
                  contentPadding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: b25Color),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: bColor),
                  ),
                ),
                onChanged: (number) {
                  _phone = number;
                },
              ),
            ),
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.5.w, 1.25.h, 1.25.w, 1.25.h),
                    padding: EdgeInsets.fromLTRB(5.w, 1.25.h, 1.25.w, 1.25.h),
                    width: 62.5.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 0.75.sp,
                          color: b25Color,
                        )),
                    child: (this.postCode.isEmpty && this.region.isEmpty)
                        ? Text(
                            Provider.of<MyUserInfo>(context, listen: false)
                                .region,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            '(${this.postCode}) ${this.region}',
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.fromLTRB(1.25.w, 1.25.h, 0, 1.25.h),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KpostalView(
                              useLocalServer: true,
                              localPort: 8080,
                              callback: (Kpostal result) {
                                setState(
                                  () {
                                    this.postCode = result.postCode;
                                    this.region = result.address;
                                    this.latitude = result.latitude.toString();
                                    this.longitude =
                                        result.longitude.toString();
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '우편번호',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 1.25.h, 20.w, 2.5.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {
                  if (_SignupKey.currentState!.validate()) {
                    _update();
                    Navigator.pop(context);
                  }
                  ;
                },
                child: Text(
                  '회원정보 수정',
                  style: TextStyle(
                    color: yColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
