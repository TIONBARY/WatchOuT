import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class SetPageRadioButton extends StatefulWidget {
  const SetPageRadioButton({
    Key? key,
    required this.texts,
    required this.values,
    required this.onchangeds,
  }) : super(key: key);
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
        padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 0.5.h),
        margin: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
        decoration: BoxDecoration(
          color: b25Color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: b25Color.withOpacity(0.125),
              offset: Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.texts,
              style: TextStyle(
                fontFamily: 'HanSan',
              ),
            ),
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
