import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  String text = "";
  Widget Function(BuildContext)? pageBuilder;

  CustomDialog(this.text, this.pageBuilder);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)), //this right here
      child: Container(
        height: 100,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Title(
                color: Colors.cyan,
                child: Text(
                  text,
                ),
              ),
              Container(
                width: 60,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    "확인",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
