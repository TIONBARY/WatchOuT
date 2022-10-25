import 'package:flutter/material.dart';

class MainPageTextButton extends StatelessWidget {
  const MainPageTextButton({
    Key? key,
    required this.flexs,
    required this.margins,
    required this.boxcolors,
    required this.onpresseds,
    required this.texts,
    required this.textcolors,
    required this.fontsizes,
  }) : super(key: key);
  final flexs;
  final margins;
  final boxcolors;
  final onpresseds;
  final texts;
  final textcolors;
  final fontsizes;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flexs,
      child: Container(
        margin: margins,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: boxcolors),
        child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          onPressed: onpresseds,
          child: Text(
            texts,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textcolors,
              fontSize: fontsizes,
            ),
          ),
        ),
      ),
    );
  }
}
