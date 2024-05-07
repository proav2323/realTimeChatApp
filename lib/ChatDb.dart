import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Chat.dart';
import 'package:realtimechatapp/Messages.dart';
import 'package:realtimechatapp/User.dart';
import 'package:uuid/uuid.dart';

class ChatDb {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<Chat>?> getAllUserChats(String userId) async {
    DocumentReference userRef = db.collection("users").doc(userId);

    CollectionReference chatRef = userRef.collection("chats");

    QuerySnapshot chatQ = await chatRef.get();

    List chats = chatQ.docs;
    List<Chat> newChats = [];

    for (int i = 0; i < chats.length; i++) {
      Chat ch = await getChat(chats[i], userId);
      newChats.add(ch);
    }
    return newChats;
  }

  Future<bool> sendMessage(
      String message, String senderid, String reciverId) async {
    await db
        .collection("users")
        .doc(senderid)
        .collection("chats")
        .doc(reciverId)
        .set({
      "id": reciverId,
      "lastMessage": message,
      "lastMessageAt": Timestamp.now(),
    });
    var uuid = Uuid();
    String id = uuid.v4();
    await db
        .collection("users")
        .doc(senderid)
        .collection("chats")
        .doc(reciverId)
        .collection("messages")
        .doc(id)
        .set({
      "senderId": senderid,
      "reciverId": reciverId,
      "message": message,
      "deleted": false,
      "edited": false,
      "createdAt": Timestamp.now(),
      "seen": false,
      "id": id,
    });

    await db
        .collection("users")
        .doc(reciverId)
        .collection("chats")
        .doc(senderid)
        .set({
      "id": senderid,
      "lastMessage": message,
      "lastMessageAt": Timestamp.now(),
    });
    await db
        .collection("users")
        .doc(reciverId)
        .collection("chats")
        .doc(senderid)
        .collection("messages")
        .doc(id)
        .set({
      "senderId": senderid,
      "reciverId": reciverId,
      "message": message,
      "deleted": false,
      "edited": false,
      "createdAt": Timestamp.now(),
      "seen": false,
      "id": id,
    });

    return true;
  }

  Future<Chat> getChat(dynamic data, String userId) async {
    List<Messages> messages = await getMessages(userId, data.get("id"));
    Auth auth = Auth(callback: () {});
    User secondUser = await auth.getUserDb(data.get("id"));

    Chat chat = Chat(
      id: data.get("id"),
      messages: messages,
      secondUser: secondUser,
      lastMessage: data.get("lastMessage"),
      lastMessageAt: data.get("lastMessageAt"),
    );

    return chat;
  }

  Future<List<Messages>> getMessages(String userId, String chatId) async {
    DocumentReference userRef = db.collection("users").doc(userId);

    DocumentReference chatsRef = userRef.collection("chats").doc(chatId);
    CollectionReference messageRef = chatsRef.collection("messages");

    QuerySnapshot chatQ = await messageRef.get();

    List chats = chatQ.docs;
    List<Messages> newChats = [];

    chats.forEach((element) {
      Messages ch = getMessage(element);
      newChats.add(ch);
    });

    return newChats;
  }

  Messages getMessage(dynamic data) {
    return Messages(
        senderId: data.get("senderId"),
        reciverId: data.get("reciverId"),
        message: data.get("message"),
        deleted: data.get("deleted"),
        edited: data.get("edited"),
        created_at: data.get("createdAt"),
        seen: data.get("seen"),
        id: data.get("id"));
  }

  Future<bool> updateMessage(String chatId, String messageId, String userId,
      String mes, String chatLastMessage, String prevMessage) async {
    if (chatLastMessage == prevMessage) {
      await db
          .collection("users")
          .doc(userId)
          .collection("chats")
          .doc(chatId)
          .update({
        "lastMessage": mes,
      });
    }
    await db
        .collection("users")
        .doc(userId)
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .update({
      "message": mes,
      "edited": true,
    });

    if (chatLastMessage == prevMessage) {
      await db
          .collection("users")
          .doc(chatId)
          .collection("chats")
          .doc(userId)
          .update({
        "lastMessage": mes,
      });
    }

    await db
        .collection("users")
        .doc(chatId)
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .doc(messageId)
        .update({
      "message": mes,
      "edited": true,
    });

    return true;
  }

  Future<bool> deleteMessage(String chatId, String messageId, String userId,
      String chatLastMessage, String prevMessage) async {
    if (chatLastMessage == prevMessage) {
      await db
          .collection("users")
          .doc(chatId)
          .collection("chats")
          .doc(userId)
          .update({
        "lastMessage": "message was deleted",
      });

      await db
          .collection("users")
          .doc(userId)
          .collection("chats")
          .doc(chatId)
          .update({
        "lastMessage": "message was deleted",
      });
    }

    await db
        .collection("users")
        .doc(userId)
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .update({"deleted": true});
    await db
        .collection("users")
        .doc(chatId)
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .doc(messageId)
        .update({"deleted": true});

    return true;
  }

  Future<bool> updateProfile(String name, File? Img, String userId) async {
    if (Img != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final uploadTask = storageRef.child("images/${basename(Img.path)}");

      try {
        await uploadTask.putFile(Img);
        String url = await storageRef
            .child("images/${basename(Img.path)}")
            .getDownloadURL();

        await db
            .collection("users")
            .doc(userId)
            .update({"name": name, "profileImg": url});

        return true;
      } on FirebaseException catch (e) {
        return false;
      }
    } else {
      await db
          .collection("users")
          .doc(userId)
          .update({"name": name, "profileImg": url});

      return true;
    }
  }
}
