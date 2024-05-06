import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Messages.dart';
import 'package:realtimechatapp/User.dart';

class Chat {
  String id;
  List<Messages> messages;
  String lastMessage;
  Timestamp lastMessageAt;
  User secondUser;

  Chat({
    required this.id,
    required this.messages,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.secondUser,
  });
}
