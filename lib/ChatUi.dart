import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Chat.dart';
import 'package:realtimechatapp/ChatDb.dart';
import 'package:realtimechatapp/Messages.dart';
import 'package:realtimechatapp/NewChat.dart';
import 'package:realtimechatapp/User.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class ChatUi extends StatefulWidget {
  ChatUi({super.key, required this.e});
  dynamic e;

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  Chat? chat = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted == true && context.read<UserCubit>().state != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(context.read<UserCubit>().state!.id)
          .collection("chats")
          .doc(widget.e.get("id"))
          .collection("messages")
          .where("reciverId", isEqualTo: context.read<UserCubit>().state!.id)
          .where("seen", isEqualTo: false)
          .get()
          .then((value) {
        List<Messages> mes = [];
        if (value.docs.isNotEmpty) {
          value.docs.forEach((data) {
            mes.add(ChatDb().getMessage(data));
          });
        }
        Auth auth = Auth(callback: () {});
        auth.getUserDb(widget.e.get("id")).then((valuee) {
          if (mounted == true) {
            setState(() {
              chat = Chat(
                id: widget.e.get("id"),
                messages: mes,
                secondUser: valuee,
                lastMessage: widget.e.get("lastMessage"),
                lastMessageAt: widget.e.get("lastMessageAt"),
              );
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return chat != null
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewChat(
                            id: chat!.id,
                            userUi: false,
                            chatLastMessage: chat!.lastMessage,
                          )));
            },
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  chat!.secondUser.profileImg != ""
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 2, top: 2, bottom: 2, right: 2),
                              child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                chat!.secondUser.profileImg ?? "",
                              ))))
                      : const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.account_circle),
                        ),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat!.secondUser.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        chat!.lastMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).disabledColor,
                        ),
                      )
                    ],
                  )),
                  chat!.messages.length >= 1
                      ? Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(24)),
                          margin: EdgeInsets.only(right: 5),
                          child: Center(
                              child: Text(chat!.messages.length.toString())),
                        )
                      : const SizedBox()
                ],
              ),
            ))
        : const SizedBox();
  }
}
