import 'package:flutter/material.dart';

class EmergencyCar extends StatelessWidget {
  const EmergencyCar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset("assets/교통사고2.png"),
          Image.asset("assets/교통사고8.jpg"),
          Image.asset("assets/교통사고3.png"),
          Image.asset("assets/교통사고4.png"),
          Image.asset("assets/교통사고5.png"),
          Image.asset("assets/교통사고6.png"),
          Image.asset("assets/교통사고1.png"),
          Image.asset("assets/교통사고7.jpg"),
        ],
      ),
    );
  }
}
