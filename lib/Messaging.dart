import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  NotificationSettings? notificationSettings;
  String? apnsToken;
  String? fcmToken;

  Future<void> init() async {
    notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);
    apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BMSimRkGSeh7eCnChGl37uz1g7EbSQvkaG9trfoIsHCirxN1jrDa6wkZyXnuZKcBNyv0Py1OCysjU0X2p2sHF3Q");

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
  }
}
