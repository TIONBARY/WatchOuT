import 'package:button_animations/button_animations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MainPageAniBtn extends StatelessWidget {
  const MainPageAniBtn({
    Key? key,
    required this.margins,
    required this.types,
    required this.ontaps,
    required this.texts,
    required this.colors,
  }) : super(key: key);
  final margins;
  final types;
  final ontaps;
  final texts;
  final colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margins,
      child: AnimatedButton(
        width: 30.w,
        blurRadius: 7.5,
        isOutline: true,
        type: types,
        onTap: ontaps,
        child: Text(
          texts,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors,
          ),
        ),
      ),
    );
  }
}
