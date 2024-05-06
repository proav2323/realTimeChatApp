import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  String senderId;
  String reciverId;
  String message;
  bool deleted;
  bool edited;
  bool seen;
  String id;
  Timestamp created_at;

  Messages(
      {required this.senderId,
      required this.reciverId,
      required this.message,
      required this.deleted,
      required this.edited,
      required this.created_at,
      required this.seen,
      required this.id});
}
