import 'package:flutter/material.dart';

class EmergencyStalking extends StatelessWidget {
  const EmergencyStalking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      key: Key('Content'),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "스토킹 처벌법",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ),
          ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 3),
              title: Text(
                '스토킹 범죄의 처벌 등에 관한 법률(약칭: 스토킹 처벌법) 2021.10.21부터 시행',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Container(
                width: 300,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Row(
                  children: [
                    Flexible(
                        child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 500,
                      strutStyle: StrutStyle(fontSize: 14),
                      text: TextSpan(
                          text:
                              "1. '스토킹 행위'란 상대방의 의사에 반하여 정당한 이유없이 상대방 또는 그의 동거인, 가족에 대하여 다음 각목의 어느하나에 해당하는 행위를 하여 상대방에게 불안감 또는 공포심을 일으키는 것을 말한다.\n"
                              "가.접근하거나 따라다니거나 진로를 막아서는 행위\n"
                              "나.주거,직장,학교, 그 밖에 일상적으로 생활하는 장소(이하'주거등'이라 한다)또는 그 부근에서 기다리거나 지켜보는 행위\n"
                              "다.우편,전화,팩스 또는 '정보통신망 이용촉진 및 정보보호 등에 관한 법률' 제2조 제1항 제1호의 정보통신망을 이용하여 물건이나 글,말,부호,음향,그림,영상,화상(이하 '물건 등'이라 한다)을 도달하게 하는 행위\n"
                              "라.직접 또는 제삼자를 통하여 물건 등을 도달하게 하거나 주거등 또는 그 부근에 물건 등을 두는 행위\n"
                              "마.주거등 또는 그 부근에 놓여져 있는 물건등을 훼손하는 행위",
                          style: TextStyle(color: Colors.black)),
                    ))
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              '스토킹 신고를 하면 스토킹 처벌법에서는 경찰이 아래와 같은 조치를 취한다',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Divider(height: kToolbarHeight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Description',
              style: TextStyle(fontSize: 10),
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
          ),
          Divider(height: kToolbarHeight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('How to apply', style: TextStyle(fontSize: 10)),
          ),
          SizedBox(height: 16.0),
          Card(
            elevation: 0.0,
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            color: Colors.white10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
            ),
          ),
          SizedBox(height: 80.0),
        ],
      ),
    );
  }
}
