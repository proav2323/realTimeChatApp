import 'package:flutter/material.dart';
import 'package:realtimechatapp/NewChat.dart';
import 'package:realtimechatapp/User.dart';

class UserUi extends StatefulWidget {
  UserUi({super.key, required this.e});
  dynamic e;

  @override
  State<UserUi> createState() => _UserUiState();
}

class _UserUiState extends State<UserUi> {
  User? user = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user = User(
        name: widget.e.get("name"),
        id: widget.e.get("id"),
        email: widget.e.get("email"),
        token: widget.e.get("token"),
        online: widget.e.get("online"),
        profileImg: widget.e.get("profileImg"),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewChat(
                            id: user!.id,
                            userUi: true,
                          )));
            },
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  user!.profileImg != ""
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 2, top: 2, bottom: 2, right: 2),
                              child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                user!.profileImg ?? "",
                              ))))
                      : const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.account_circle),
                        ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        user!.online ? "Online" : "Offline",
                        style: TextStyle(
                            color: user!.online ? Colors.green : Colors.red),
                      )
                    ],
                  ),
                ],
              ),
            ))
        : const SizedBox();
  }
}
