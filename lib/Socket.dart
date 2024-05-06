import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtimechatapp/Auth.dart';
import "package:socket_io_client/socket_io_client.dart" as IO;
import 'dart:developer';

class Socket {
  static IO.Socket socket = IO.io(
      "https://realtimechatappbackend-p1b7.onrender.com/", <String, dynamic>{
    'autoConnect': false,
    'transports': ['websocket'],
  });
  static bool connected = false;
  static bool loading = false;
  Function(bool chnage) callabck;

  Socket({required this.callabck});

  init() {
    if (socket.connected == false) {
      log("started");
      loading = true;
      callabck(false);
      socket = socket.connect();
      socket.onConnect((sockett) async {
        log("Connection established", name: "socket conect");
        connected = true;
        if (FirebaseAuth.instance.currentUser != null) {
          log("this changing", name: "chaning");
          await Auth(callback: () {}).upadetSocket(
              FirebaseAuth.instance.currentUser!.uid, socket.id ?? "");
          await Auth(callback: () {})
              .upadetOnline(FirebaseAuth.instance.currentUser!.uid, true);
          log("this is done", name: "chaning");
        }
        loading = false;
        callabck(true);
      });
      socket.onDisconnect((socket) async {
        log("connection Disconnection", name: "socte dis");
        connected = false;
        if (FirebaseAuth.instance.currentUser != null) {
          await Auth(callback: () {})
              .upadetOnline(FirebaseAuth.instance.currentUser!.uid, false);
        }
        loading = false;
        callabck(true);
      });
      socket.onConnectError((err) {
        log(err, name: "socket");
        connected = false;
        loading = false;
        callabck(false);
      });
      socket.onError((err) {
        log(err, name: "socket roor");
        connected = false;
        loading = false;
        callabck(false);
      });
    }
  }

  getConnected() {
    return connected;
  }

  getLoading() {
    return loading;
  }

  getSocket() {
    return socket;
  }
}
