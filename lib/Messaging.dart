import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class Messaging {
  NotificationSettings? notificationSettings;
  String? apnsToken;
  String? fcmToken;
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
    apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BMSimRkGSeh7eCnChGl37uz1g7EbSQvkaG9trfoIsHCirxN1jrDa6wkZyXnuZKcBNyv0Py1OCysjU0X2p2sHF3Q");
    await Clipboard.setData(ClipboardData(text: fcmToken ?? ""));

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      log(fcmToken, name: "token");
    }).onError((err) {});

    await FirebaseMessaging.instance.subscribeToTopic(fcmToken ?? "");
  }

  updateToken(String userId) async {
    await db.collection("users").doc(userId).update({"token": fcmToken ?? ""});
  }
}
