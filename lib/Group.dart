import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtimechatapp/GroupMessages.dart';

class Group {
  String createdBy;
  String id;
  String lastMessage;
  Timestamp lastMessageAt;
  List<dynamic> members;
  List<GroupMessages> messages;
  String name;

  Group({
    required this.createdBy,
    required this.id,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.members,
    required this.messages,
    required this.name,
  });
}
