import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtimechatapp/User.dart' as us;

class Auth {
  Function callback;
  FirebaseFirestore db = FirebaseFirestore.instance;
  Auth({required this.callback});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        us.User user = await getUserDb(credential.user!.uid);
        return {"user": user, "error": ""};
      } else {
        return {"error": "soemthign went wrong"};
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {"error": "wser not found with this email"};
      } else if (e.code == 'wrong-password') {
        return {"error": "wrong credntials"};
      } else {
        return {"error": e.message ?? ""};
      }
    } catch (e) {
      return {"error": "something went wrong"};
    }
  }

  Future<Map<String, dynamic>> signUp(
      String email, String password, String name) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        us.User user =
            await createUser(email, credential.user!.uid, name, "", "");
        return {"user": user, "error": ""};
      } else {
        return {"error": "soemthign went wrong"};
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-found') {
        return {"error": "user found with this email"};
      } else if (e.code == 'wrong-password') {
        return {"error": "wrong credentials"};
      } else {
        log(e.message ?? "", name: "err");
        return {"error": e.message ?? ""};
      }
    } catch (e) {
      return {"error": "something went wrong"};
    }
  }

  Future<us.User> getUserDb(String id) async {
    DocumentSnapshot<Map<String, dynamic>> data =
        await db.collection("users").doc(id).get();

    us.User newUser = us.User(
      name: data.get("name"),
      id: data.get("id"),
      email: data.get("email"),
      socketId: data.get("socketId"),
      online: data.get("online"),
      profileImg: data.get("profileImg") ?? null,
    );
    return newUser;
  }

  Future<us.User> createUser(String email, String id, String name,
      String socketId, String profileImg) async {
    await db.collection("users").doc(id).set({
      "email": email,
      "id": id,
      "name": name,
      "socketId": socketId,
      "profileImg": profileImg,
      "online": true,
    });

    us.User newUser = await getUserDb(id);
    return newUser;
  }

  upadetSocket(String id, String socket) async {
    await db.collection("users").doc(id).update({"socketId": socket});
  }

  upadetOnline(String id, bool value) async {
    await db.collection("users").doc(id).update({"online": value});
  }
}
