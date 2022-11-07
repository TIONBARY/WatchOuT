import 'package:flutter/material.dart';

class EmergencyDisaster extends StatelessWidget {
  const EmergencyDisaster({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset("assets/natural_disaster/재해2.jpeg"),
          Image.asset("assets/natural_disaster/재해1.JPG"),
          Image.asset("assets/natural_disaster/재해3.jpg"),
          Image.asset("assets/natural_disaster/재해4.jpg"),
          Image.asset("assets/natural_disaster/재해5.jpg"),
          Image.asset("assets/natural_disaster/재해6.jpg"),
          Image.asset("assets/natural_disaster/재해7.jpg"),
          Image.asset("assets/natural_disaster/재해8.jpg"),
          Image.asset("assets/natural_disaster/재해9.png"),
          Image.asset("assets/natural_disaster/재해10.jpg"),
        ],
      ),
    );
  }
}
