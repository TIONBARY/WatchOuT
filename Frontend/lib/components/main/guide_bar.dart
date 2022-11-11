import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:homealone/components/main/intro_guide.dart';
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
      margin: EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: b25Color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.all(8),
            child: Text('가이드 보러가기'),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                minimumSize: Size.zero,
                padding: EdgeInsets.all(2),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: bColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Intro(
                      padding: EdgeInsets.zero,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      maskColor: const Color.fromRGBO(0, 0, 0, .6),
                      child: const MainGuide(),
                    ),
                  ),
                );
              },
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
