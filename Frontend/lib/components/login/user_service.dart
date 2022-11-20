import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserService {
  FirebaseAuth authentication = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<bool> isActivated() async {
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc("${user?.uid}");
    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null)
      debugPrint("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData?["activated"];
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc("${user?.uid}");
    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null)
      debugPrint("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData;
  }

  Future<Map<String, dynamic>?> getOtherUserInfo(String uid) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc(uid);
    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null)
      debugPrint("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData;
  }

  Future<bool> isDupNum(String number) async {
    bool flag = true;
    await db
        .collection("user")
        .where("phone", isEqualTo: number)
        .get()
        .then((value) => {
              debugPrint("\nlength ; ${value.docs.length}\n"),
              if (value.docs.length == 0) {flag = false},
            });
    return flag;
  }

  void registerBasicUserInfo() {
    db.collection("user").doc("${user?.uid}").set({
      "googleUID": "${user?.uid}",
      "profileImage": "${user?.photoURL}",
      "phone": "01012345678",
      "birth": "000101",
      "blocked": false,
      "activated": false,
      "region": "12345", //(시군구번호)
      "nickname": "구의동호랑이",
      "name": "홍길동",
      "gender": "M",
      "hide": false,
      "latitude": "",
      "longitude": "",
    });
  }

  void registerFirstResponder(String name, String number) {
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("firstResponder")
        .doc(name)
        .set({
      "number": number,
      "appUser": false,
      "uid": '',
      // "phone": false,
      // "message": false,
      // "activated": false
    });
  }

  void deleteFirstResponder(String name) {
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("firstResponder")
        .doc(name)
        .delete();
  }

  void deleteFirstResponderList(List<Map<String, dynamic>> data) {
    for (int i = 0; i < data.length; i++) {
      db
          .collection("user")
          .doc("${user?.uid}")
          .collection("firstResponder")
          .doc(data[i]["name"])
          .delete();
    }
  }

  Future<void> deleteUser() async {
    await db.collection("user").doc("${user?.uid}").delete();
    await authentication.signOut();
  }

  void updateUser(
      String photoUrl,
      String phone,
      String birth,
      String region,
      String nickname,
      String name,
      String gender,
      String latitude,
      String longitude) {
    void deleteFirstResponderList(List<Map<String, dynamic>> selectedList) {
      for (int i = 0; i < selectedList.length; i++) {
        db
            .collection("user")
            .doc("${user?.uid}")
            .collection("firstResponder")
            .doc(selectedList[i]["name"])
            .delete();
      }
    }

    void updateUser(String photoUrl, String phone, String birth, String region,
        String nickname, String name, String gender) {
      db.collection("user").doc("${user?.uid}").update({
        "profileImage": photoUrl,
        "phone": phone,
        "birth": birth,
        "region": region,
        "nickname": nickname,
        "name": name,
        "gender": gender,
        "latitude": latitude,
        "longitude": longitude,
      });
    }
  }

  //홈 캠 관련 함수
  void homeCamRegister(String url) {
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("homecam")
        .doc("myCamInfo")
        .set({
      "registered": true,
      "url": url,
    });
  }

  void deleteHomecam() {
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("homecam")
        .doc("myCamInfo")
        .delete();
  }

  void updateHomecamUrl(String url) {
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("homecam")
        .doc("myCamInfo")
        .update({
      "registered": true,
      "url": url,
    });
  }

  Future<Map<String, dynamic>?> getHomecamInfo() async {
    DocumentReference<Map<String, dynamic>> documentReference = db
        .collection("user")
        .doc("${user?.uid}")
        .collection("homecam")
        .doc("myCamInfo");

    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    return documentData;
  }

  Future<String> getHomecamUrl() async {
    DocumentReference<Map<String, dynamic>> documentReference = db
        .collection("user")
        .doc("${user?.uid}")
        .collection("homecam")
        .doc("myCamInfo");

    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }

    if (documentData == null) {
      debugPrint("캠 관련 url을 불러오지 못했습니다.");
      return "error";
    }
    return documentData["url"];
  }

  Future<bool> isHomecamRegistered() async {
    DocumentReference<Map<String, dynamic>> documentReference = db
        .collection("user")
        .doc("${user?.uid}")
        .collection("homecam")
        .doc("myCamInfo");
    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null) {
      debugPrint("등록된 캠 정보가 없습니다.");
      return false;
    }
    return documentData?["registered"];
  }

  //앱 사용자 간 비상 연락망 검색
  Future<Map<String, dynamic>?> getUserInfoByNumber(String number) async {
    // where 쿼리문으로 검색 후 Map 형태로 가공하여 반환하기
    List<QueryDocumentSnapshot> data;
    Map<String, dynamic>? result;
    var querySnapshot =
        await db.collection("user").where("phone", isEqualTo: number).get();
    data = querySnapshot.docs;
    if (data.isEmpty) {
      debugPrint("해당 번호에 해당하는 유저가 없습니다.");
    } else {
      result = data[0].data() as Map<String, dynamic>?;
    }
    return result;
  }

  //비상 연락망 검색 후 등록
  void registerExistFirstResponder(String name, String number, String uid) {
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("firstResponder")
        .doc(name)
        .set({
      "number": number,
      "appUser": true,
      "uid": uid,
      "CamActivated": false,
    });
  }

  // 위급상황 여부를 나타냄
  // 0. 회원 가입시 false
  // 1. 위급 상황 발생시 true로 변경
  // 2. 본인이 취소 시 false 로 변경
  void updateHEmergencyStatus(bool flag) {
    db.collection("user").doc("${user?.uid}").update({
      "SOS": flag,
    });
  }

  // 위급상황 여부를 나타냄
  Future<bool> isEmergency() async {
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc("${user?.uid}");
    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null) {
      debugPrint("등록된 위급상황 정보가 없습니다.");
      return false;
    }
    return documentData?["SOS"];
  }

  // 친구 추천 코드로 추가
  Future<String> registerFirstResponderFromInvite(String inviteCode) async {
    // 친구정보 가져오기
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc(inviteCode);
    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }

    if (documentData == null) {
      debugPrint("초대한 친구가 존재하지 않습니다.");
      return "failed";
    }
    String name = documentData["name"];
    String number = documentData["phone"];
    // 내 정보에 저장
    db
        .collection("user")
        .doc("${user?.uid}")
        .collection("firstResponder")
        .doc(name)
        .set({
      "number": number,
      "uid": inviteCode,
      // "message": false,
      // "activated": false
    });
    return "success";
  }

  // 내 연락처 중에 웹캠이 있는 사람의 목록(작업중)
  void getFirstResponderWithCamList(List<Map<String, dynamic>> data) {
    for (int i = 0; i < data.length; i++) {
      db
          .collection("user")
          .doc("${user?.uid}")
          .collection("firstResponder")
          .doc(data[i]["name"]);
    }
  }

  // 선택한 다른 유저의 웹캠 주소
  Future<String> getFreindHomecamUrl(String friendUid) async {
    DocumentReference<Map<String, dynamic>> documentReference = db
        .collection("user")
        .doc(friendUid)
        .collection("homecam")
        .doc("myCamInfo");

    Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }

    if (documentData == null) {
      debugPrint("캠 관련 url을 불러오지 못했습니다.");
      return "error";
    }
    return documentData["url"];
  }
}
