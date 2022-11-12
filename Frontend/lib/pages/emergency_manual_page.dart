import 'package:flutter/material.dart';
import 'package:homealone/components/emergencyManual/car_accident.dart';
import 'package:homealone/components/emergencyManual/kidnap.dart';
import 'package:homealone/components/emergencyManual/natural_disaster.dart';
import 'package:homealone/components/emergencyManual/safety_accident.dart';
import 'package:homealone/components/emergencyManual/stalking.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class EmergencyManual extends StatelessWidget {
  const EmergencyManual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          centerTitle: true,
          title: Text(
            "위기상황 대처메뉴얼",
            style: TextStyle(
              color: yColor,
              fontSize: 15.sp,
            ),
          ),
          backgroundColor: bColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.83.h),
            child: TabBar(
              isScrollable: true,
              unselectedLabelColor: y75Color,
              labelColor: yColor,
              indicatorColor: yColor,
              tabs: [
                Tab(
                  child: Text("스토킹/폭행"),
                ),
                Tab(
                  child: Text("납치/유괴"),
                ),
                Tab(
                  child: Text("교통사고"),
                ),
                Tab(
                  child: Text("안전사고"),
                ),
                Tab(
                  child: Text("자연재해"),
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: EmergencyStalking(),
            ),
            Center(
              child: EmergencyKidnap(),
            ),
            Center(
              child: EmergencyCar(),
            ),
            Center(
              child: EmergencySafety(),
            ),
            Center(
              child: EmergencyDisaster(),
            ),
          ],
        ),
      ),
    );
  }
}
