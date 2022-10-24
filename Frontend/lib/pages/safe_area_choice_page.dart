import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/components/safearea/safe_area_choice_buttion.dart';

class SafeAreaChoicePage extends StatefulWidget {
  const SafeAreaChoicePage({Key? key}) : super(key: key);

  @override
  State<SafeAreaChoicePage> createState() => _SafeAreaChoiceState();
}

class _SafeAreaChoiceState extends State<SafeAreaChoicePage> {
  final _authentication = FirebaseAuth.instance;

  final locations = ["편의점", "파출소", "약국", "병원", "안심 택배", "비상벨"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: 6, //item 개수
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 1, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 10, //수평 Padding
          crossAxisSpacing: 10, //수직 Padding
        ),
        itemBuilder: (BuildContext context, int index) {
          //item 의 반목문 항목 형성
          return Container(
            child: SafeAreaChoiceButton('${locations[index]}'),
          );
        },
      ),
    );
  }
}
