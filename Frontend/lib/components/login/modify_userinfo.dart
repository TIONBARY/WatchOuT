import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  String? _phone = '';

  String postCode = '';
  String region = '';
  String latitude = '';
  String longitude = '';

  late TextEditingController _phoneController;

  XFile? profileImage;
  final picker = ImagePicker();
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL = "";

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
        String address = Provider.of<MyUserInfo>(context, listen: false).region;
        this.postCode = address.substring(1, 6);
        this.region = address.substring(8);
        print('지역: $this.region');
        this.latitude =
            Provider.of<MyUserInfo>(context, listen: false).latitude;
        this.longitude =
            Provider.of<MyUserInfo>(context, listen: false).longitude;
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
      "phone": _phone,
      "region": '(${this.postCode}) ${this.region}',
      "latitude": '${this.latitude}',
      "longitude": '${this.longitude}',
      "profileImage": '${_profileImageURL}',
      "activated": true,
    });
  }

  bool _isValidPhone(String val) {
    return RegExp(r'^010\d{7,8}$').hasMatch(val);
  }

  void _uploadImageToStorage() async {
    XFile? choosedimage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (choosedimage == null) return;
    setState(() {
      profileImage = choosedimage!;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    Reference storageReference =
        _firebaseStorage.ref().child("profile/${loggedUser!.uid}");

    // 파일 업로드
    UploadTask storageUploadTask =
        storageReference.putFile(new File(profileImage!.path));

    // 파일 업로드 완료까지 대기
    TaskSnapshot taskSnapshot = await storageUploadTask;
    // 업로드한 사진의 URL 획득
    String downloadURL = await storageReference.getDownloadURL();

    // 업로드된 사진의 URL을 페이지에 반영
    setState(() {
      _profileImageURL = downloadURL;
    });
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
                      ),
                    ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
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
                      _uploadImageToStorage();
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
                  print('onChanged: $number');
                },
                onSaved: (number) {
                  setState(
                    () {
                      this._phone = number;
                    },
                  );
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
                Container(
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
                                  this.longitude = result.longitude.toString();
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
