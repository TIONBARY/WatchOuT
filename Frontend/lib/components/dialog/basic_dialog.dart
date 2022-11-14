import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';

class BasicDialog extends StatelessWidget {
  final EdgeInsetsGeometry paddings;
  final double heights;
  final String titles;
  final Widget Function(BuildContext)? pageBuilder;

  BasicDialog(this.paddings, this.heights, this.titles, this.pageBuilder,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      child: Container(
        padding: paddings,
        height: heights,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Title(
              color: bColor,
              child: Text(
                titles,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: () {
                if (pageBuilder == null) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.push(
                      context, MaterialPageRoute(builder: pageBuilder!));
                }
              },
              child: Text(
                '확인',
                style: TextStyle(color: bColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
