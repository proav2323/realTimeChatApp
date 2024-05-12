import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupMessages.dart';
import 'package:uuid/uuid.dart';

class GroupDb {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Future<bool> createGroup(
      String name, List<String> members, String createdBy) async {
    String id = Uuid().v4();
    await db.collection("groups").doc(id).set({
      "name": name,
      "members": members,
      "createdBy": createdBy,
      "id": id,
      "lastMessage": "",
      "lastMessageAt": Timestamp.now()
    });

    return true;
  }

  Future<Group> getChat(dynamic data) async {
    List<GroupMessages> messages = await getMessages(data.get("id"));

    Group chat = Group(
      id: data.get("id"),
      messages: messages,
      lastMessage: data.get("lastMessage"),
      lastMessageAt: data.get("lastMessageAt"),
      createdBy: data.get("createdBy"),
      members: data.get("members"),
      name: data.get("name"),
    );

    return chat;
  }

  Future<List<GroupMessages>> getMessages(String id) async {
    DocumentReference userRef = db.collection("groups").doc(id);

    CollectionReference messageRef = userRef.collection("messages");

    QuerySnapshot chatQ = await messageRef.get();

    List chats = chatQ.docs;
    List<GroupMessages> newChats = [];

    chats.forEach((element) {
      GroupMessages ch = getMessage(element);
      newChats.add(ch);
    });

    return newChats;
  }

  GroupMessages getMessage(dynamic data) {
    return GroupMessages(
      senderId: data.get("senderId"),
      message: data.get("message"),
      deleted: data.get("deleted"),
      edited: data.get("edited"),
      created_at: data.get("createdAt"),
      seen: data.get("seen"),
      id: data.get("id"),
      recieverId: data.get("recieverId"),
    );
  }
}
