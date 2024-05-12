import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessages {
  String senderId;
  String message;
  bool deleted;
  bool edited;
  List<String> seen;
  String id;
  Timestamp created_at;

  GroupMessages({
    required this.senderId,
    required this.message,
    required this.deleted,
    required this.edited,
    required this.created_at,
    required this.seen,
    required this.id,
  });
}
