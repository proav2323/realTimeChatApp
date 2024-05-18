import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Messaging {
  NotificationSettings? notificationSettings;
  String? apnsToken;
  String? fcmTokenn;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> init() async {
    notificationSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      log(fcmToken, name: "token");
      if (FirebaseAuth.instance.currentUser != null) {
        updateToken(FirebaseAuth.instance.currentUser!.uid, fcmToken);
      }
    }).onError((err) {});
    apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    fcmTokenn = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BMSimRkGSeh7eCnChGl37uz1g7EbSQvkaG9trfoIsHCirxN1jrDa6wkZyXnuZKcBNyv0Py1OCysjU0X2p2sHF3Q");

    if (FirebaseAuth.instance.currentUser != null) {
      updateToken(FirebaseAuth.instance.currentUser!.uid,
          fcmTokenn ?? "no token bsdjsb");
      log("fkdfknsfjn", name: "lol");
    } else {}

    FirebaseMessaging.onMessage.listen((RemoteMessage mes) {});
  }

  updateToken(String userId, String token) async {
    await db.collection("users").doc(userId).update({
      "token": FieldValue.arrayUnion([token])
    });
  }

  Future<bool> SendPushNotification(
      String reciverId, String senderId, String message) async {
    try {
      log(
          {
            "reciverId": reciverId,
            "senderId": senderId,
            "message": message,
          }.toString(),
          name: "testing");
      http.Response data = await http
          .post(Uri.https("realtimechatappbackend-p1b7.onrender.com", "send"),
              body: json.encode({
                "reciverId": reciverId,
                "senderId": senderId,
                "message": message,
              }),
              headers: {"Content-Type": "application/json"});

      if (data.statusCode == 200) {
        return true;
      } else {
        var result = jsonDecode(utf8.decode(data.bodyBytes)) as Map;
        log(result["error"], name: "error");
        return false;
      }
    } catch (Err) {
      log(Err.toString(), name: "error");
      return false;
    }
  }

  Future<bool> sendGroupPushNotification(String groupId, String senderId,
      String message, List<String> membersToken) async {
    await http.post(
        Uri.https("realtimechatappbackend-p1b7.onrender.com", "sendGroup"),
        body: json.encode({
          "groupId": groupId,
          "senderId": senderId,
          "message": message,
          "memberTokens": membersToken
        }),
        headers: {"Content-Type": "application/json"});

    return true;
  }
}
