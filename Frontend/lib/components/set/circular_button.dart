import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  const CircularButton({
    Key? key,
    required this.heights,
    required this.widths,
    required this.colors,
    required this.icons,
    required this.onpresseds,
  }) : super(key: key);

  final double heights;
  final double widths;
  final Color colors;
  final Icon icons;
  final onpresseds;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heights,
      width: widths,
      decoration: BoxDecoration(
        color: colors,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: icons,
        enableFeedback: true,
        onPressed: onpresseds,
      ),
    );
  }
}
