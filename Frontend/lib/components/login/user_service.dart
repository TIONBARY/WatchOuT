import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    if (documentData == null) print("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData?["activated"];
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    DocumentReference<Map<String, dynamic>> documentReference =
        db.collection("user").doc("${user?.uid}");
    Map<String, dynamic>? documentData;
    // Map<String, dynamic>? documentData;
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      documentData = docSnapshot.data();
    }
    if (documentData == null) print("현재 로그인 된 유저가 없음 from auth_service.dart");
    return documentData;
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
        .set({"number": number, "phone": false, "message": false});
  }

  void deleteUser() {
    db.collection("user").doc("${user?.uid}").delete();
    authentication.signOut();
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
