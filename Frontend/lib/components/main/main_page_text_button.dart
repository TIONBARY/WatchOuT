import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MainPageTextButton extends StatelessWidget {
  const MainPageTextButton({
    Key? key,
    required this.margins,
    required this.boxcolors,
    required this.onpresseds,
    required this.texts,
    required this.textcolors,
    required this.fontsizes,
  }) : super(key: key);
  final margins;
  final boxcolors;
  final onpresseds;
  final texts;
  final textcolors;
  final fontsizes;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        margin: margins,
        width: double.infinity,
        child: AnimatedButton(
          width: 27.5.w,
          type: PredefinedThemes.warning,
          blurRadius: 10,
          borderRadius: 25,
          isOutline: true,
          onTap: onpresseds,
          child: Text(
            texts,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textcolors,
              fontSize: fontsizes,
            ),
          ),
        ),
        // child: TextButton(
        //   style: ButtonStyle(
        //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        //       RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(25),
        //       ),
        //     ),
        //   ),
        //   onPressed: onpresseds,
        //   child: Text(
        //     texts,
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //       color: textcolors,
        //       fontSize: fontsizes,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
