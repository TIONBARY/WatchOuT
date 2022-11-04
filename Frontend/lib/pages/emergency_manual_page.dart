import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/pages/emergency_manual_stalking_page.dart';

class EmergencyManual extends StatelessWidget {
  const EmergencyManual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "위기상황별 대처메뉴얼",
              style: TextStyle(color: yColor, fontSize: 16.0),
            ),
            backgroundColor: nColor,
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(30.0),
                child: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.3),
                    indicatorColor: Colors.yellow,
                    tabs: [
                      Tab(
                        child: Text(
                          "스토킹/폭행",
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      Tab(
                        child: Text("납치/유괴",
                            style: TextStyle(color: Colors.yellow)),
                      ),
                      Tab(
                        child: Text("교통사고",
                            style: TextStyle(color: Colors.yellow)),
                      ),
                      Tab(
                        child: Text("안전사고",
                            style: TextStyle(color: Colors.yellow)),
                      ),
                      Tab(
                        child: Text("자연재해",
                            style: TextStyle(color: Colors.yellow)),
                      )
                    ])),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
              ),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              Container(
                child: Center(
                  child: EmergencyStalking(),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Tab 2"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Tab 3"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Tab 4"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Tab 5"),
                ),
              ),
            ],
          )),
    );
  }
}
