import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/main.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProfileBar extends StatefulWidget {
  const ProfileBar({Key? key}) : super(key: key);

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  final picker = ImagePicker();
  File? profileImage;

  Future<void> chooseImage() async {
    var choosedimage = await picker.pickImage(source: ImageSource.gallery);
    //set source: ImageSource.camera to get image from camera
    setState(() {
      profileImage = File(choosedimage!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 5,
            child: Container(
              child: SizedBox(
                height: 22.5.h,
                width: 22.5.w,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      Provider.of<MyUserInfo>(context, listen: false)
                          .profileImage),
                  child: GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return ProfileImageDialog(
                          profileImage,
                          onpresseds: () => {
                            chooseImage(),
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(left: 2.5.w),
              child: Text(
                Provider.of<MyUserInfo>(context, listen: false).name,
                style: TextStyle(fontSize: 17.5.sp),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(left: 2.5.w),
              child: IconButton(
                onPressed: () => doCheck(context),
                icon: Icon(Icons.check),
              ),
            ),
          ),
          // Flexible(flex: 3, child: Image.asset('assets/heartbeat.gif')),
        ],
      ),
    );
  }
}

void doCheck(BuildContext context) {
  myuserInfo.confirmCheck();
  print('출석 완료 ${myuserInfo.isCheck}');

  print('프로필바다트${myuserInfo.toString()}');
  print('프로필바다트${myuserInfo.hashCode}');
  print('프로필바다트${Provider.of<MyUserInfo>(context, listen: false).hashCode}');
}

// void todayCheck() {
//   DateTime now = DateTime.now();
//   Timer(
//     Duration(seconds: 20),
//     () {
//       DateTime later = DateTime.now();
//       int time_diff = ((later.year - now.year) * 8760 * 3600) +
//           ((later.month - now.month) * 730 * 3600) +
//           ((later.day - now.day) * 24 * 3600) +
//           ((later.hour - now.hour) * 3600) +
//           ((later.minute - now.minute) * 60) +
//           (later.second - now.second);
//
//       print('시간 차이 ${time_diff}');
//     },
//   );
// }

class ProfileImageDialog extends StatelessWidget {
  const ProfileImageDialog(
    this.profileImage, {
    Key? key,
    required this.onpresseds,
  }) : super(key: key);

  final onpresseds;
  final profileImage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.5),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
        height: 25.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: nColor,
              child: Text(
                "프로필 이미지 변경",
                style: TextStyle(
                  color: nColor,
                  fontSize: 15.sp,
                ),
              ),
            ),
            Container(
              height: 75,
              width: 75,
              child: profileImage == null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          Provider.of<MyUserInfo>(context, listen: false)
                              .profileImage),
                    )
                  : new CircleAvatar(
                      backgroundImage: new FileImage(
                        File(profileImage!.path),
                      ),
                    ),
            ),
            Container(
              child: ElevatedButton.icon(
                onPressed: onpresseds,
                icon: Icon(Icons.image),
                style: ElevatedButton.styleFrom(
                    backgroundColor: nColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                label: Text(
                  "프로필 이미지 선택",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
