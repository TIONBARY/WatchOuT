import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('채팅'),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}
