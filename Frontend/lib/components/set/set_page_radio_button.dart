import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class SetPageRadioButton extends StatefulWidget {
  const SetPageRadioButton({
    Key? key,
    required this.margins,
    required this.texts,
    required this.values,
    required this.onchangeds,
  }) : super(key: key);
  final margins;
  final texts;
  final values;
  final onchangeds;

  @override
  State<SetPageRadioButton> createState() => _SetPageRadioButtonState();
}

class _SetPageRadioButtonState extends State<SetPageRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.fromLTRB(25.w, 5.h, 25.w, 5.h),
        margin: widget.margins,
        decoration: BoxDecoration(
          color: n25Color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.texts),
            Switch(
              value: widget.values,
              onChanged: widget.onchangeds,
            ),
          ],
        ),
      ),
    );
  }
}
