import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    Key? key,
    required this.paddings,
    required this.keyboardtypes,
    required this.hinttexts,
    required this.helpertexts,
    required this.onchangeds,
    required this.validations,
  }) : super(key: key);

  final paddings;
  final keyboardtypes;
  final hinttexts;
  final helpertexts;
  final onchangeds;
  final validations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddings,
      child: TextFormField(
        style: TextStyle(fontFamily: 'HanSan'),
        autocorrect: false,
        validator: validations,
        keyboardType: keyboardtypes,
        textInputAction: TextInputAction.done,
        cursorColor: bColor,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hinttexts,
          hintStyle: TextStyle(fontFamily: 'HanSan'),
          helperText: helpertexts,
          helperStyle: TextStyle(fontFamily: 'HanSan'),
          errorStyle: TextStyle(fontFamily: 'HanSan'),
          contentPadding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: b25Color),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: bColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: b25Color),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: b25Color),
          ),
        ),
        onChanged: onchangeds,
      ),
    );
  }
}
