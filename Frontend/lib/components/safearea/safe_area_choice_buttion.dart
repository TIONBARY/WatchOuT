import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/safe_area_map_page.dart';
import 'package:sizer/sizer.dart';

class SafeAreaChoiceButton extends StatelessWidget {
  const SafeAreaChoiceButton(this.name);

  final name;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: n25Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SafeAreaMapPage(name)));
      },
      child: Text(
        name,
        style: TextStyle(fontSize: 25.sp),
      ),
    );
  }
}
