import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';

class GuideBar extends StatefulWidget {
  const GuideBar({Key? key}) : super(key: key);

  @override
  State<GuideBar> createState() => _GuideBarState();
}

class _GuideBarState extends State<GuideBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // boxShadow: [
        //   BoxShadow(
        //     color: b25Color,
        //     offset: Offset(0, 3),
        //     blurRadius: 5,
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.all(8),
            child: Text('가이드 보러가기'),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                minimumSize: Size.zero,
                padding: EdgeInsets.all(2),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: bColor,
              ),
              onPressed: () {},
              child: Icon(
                Icons.question_mark,
                color: yColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
