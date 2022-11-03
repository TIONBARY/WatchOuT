import 'package:flutter/material.dart';
import 'package:homealone/components/singleton/is_check.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/main.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

final isCheck = IsCheck.instance;

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
        ],
      ),
    );
  }
}

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
