import 'package:flutter/material.dart';
import 'package:homealone/googleLogin/modify_userinfo_page.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProfileBar extends StatefulWidget {
  const ProfileBar({Key? key}) : super(key: key);

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 75,
                width: 75,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      Provider.of<MyUserInfo>(context, listen: false)
                          .profileImage),
                ),
              ),
              Container(
                width: 50.w,
                child: Text(
                  Provider.of<MyUserInfo>(context, listen: false).name,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 17.5.sp),
                ),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.88,
                        child: Container(
                          height: 450.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: ModifyUserInfoPage(), // 모달 내부
                        ),
                      );
                    },
                  );
                },
                icon: Icon(Icons.edit),
              ),
            ],
          ),
          // Flexible(flex: 3, child: Image.asset('assets/heartbeat.gif')),
        ],
      ),
    );
  }
}
