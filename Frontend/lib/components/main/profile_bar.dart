import 'package:flutter/material.dart';
import 'package:homealone/components/singleton/is_check.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

final isCheck = IsCheck.instance;

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
      child: Row(
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
                  // child: GestureDetector(
                  //   onTap: () => doCheck(context),
                  // ),
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
