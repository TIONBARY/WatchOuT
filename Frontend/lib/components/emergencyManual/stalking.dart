import 'package:flutter/material.dart';

class EmergencyStalking extends StatelessWidget {
  const EmergencyStalking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset("assets/stalking/스토킹1.jpg"),
          Image.asset("assets/stalking/스토킹2.jpg"),
          Image.asset("assets/stalking/스토킹3.jpg"),
          Image.asset("assets/stalking/스토킹4.jpg"),
          Image.asset("assets/stalking/스토킹5.jpg"),
          Image.asset("assets/stalking/스토킹6.jpg"),
          Image.asset("assets/stalking/스토킹7.jpg"),
          Image.asset("assets/stalking/스토킹8.jpg"),
          Image.asset("assets/stalking/스토킹9.jpg"),
          Image.asset("assets/stalking/스토킹10.jpg"),
          Image.asset("assets/stalking/스토킹11.jpg"),
        ],
      ),
    );
  }
}
