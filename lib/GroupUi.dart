import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupChat.dart';
import 'package:realtimechatapp/NewChat.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupUi extends StatefulWidget {
  const GroupUi({super.key, required this.e});
  final dynamic e;

  @override
  State<GroupUi> createState() => _GroupUiState();
}

class _GroupUiState extends State<GroupUi> {
  Group? chat = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted == true && context.read<UserCubit>().state != null) {
      setState(() {
        chat = Group(
          id: widget.e.get("id"),
          messages: [],
          lastMessage: widget.e.get("lastMessage"),
          lastMessageAt: widget.e.get("lastMessageAt"),
          createdBy: widget.e.get("createdBy"),
          members: widget.e.get("members"),
          name: widget.e.get("name"),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return chat != null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groups")
                .doc(widget.e.get("id"))
                .collection("messages")
                .where("reciverId",
                    arrayContains: context.read<UserCubit>().state!.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                log(snapshot.error.toString(), name: "group ui error");
              }

              List<dynamic> data = [];
              if (snapshot.hasData) {
                List<dynamic> dat = snapshot.data!.docs;
                data = dat.where((value) {
                  log(value.get("seen").toString(), name: "hroup ui");
                  if (!value
                      .get("seen")
                      .contains(context.read<UserCubit>().state!.id)) {
                    return true;
                  } else {
                    return false;
                  }
                }).toList();
              }

              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupChat(
                                  id: chat!.id,
                                  userUi: false,
                                  chatLastMessage: chat!.lastMessage,
                                )));
                  },
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.group),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat!.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            chat!.lastMessage != ""
                                ? Text(
                                    chat!.lastMessage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        )),
                        snapshot.hasData == true && data.length >= 1
                            ? Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(24)),
                                margin: EdgeInsets.only(right: 5),
                                child:
                                    Center(child: Text(data.length.toString())),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ));
            })
        : const SizedBox(
            height: 1,
            width: 1,
          );
  }
}
